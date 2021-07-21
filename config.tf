


# Tenant Definition
resource "aci_tenant" "terraform_tenant" {
  # Note the names cannot be modified in ACI, use the name_alias instead
  # The name becomes the distinguished named with the model, this is the reference name
  # The model can be deployed A/B if the name, aka the model, must change
  name        = "terraform_tenant"
  name_alias  = "tenant_for_terraform"
  description = "This tenant is created by terraform ACI provider"
}

# Networking Definition
resource "aci_vrf" "vrf01" {
  tenant_dn              = "${aci_tenant.terraform_tenant.id}"
  name                   = "vrf01"
  name_alias             = "vrf01"
}

resource "aci_bridge_domain" "bd01" {
  tenant_dn   = "${aci_tenant.terraform_tenant.id}"
  name        = "bd01"
  description = "This bridge domain is member of vrf01"
  relation_fv_rs_ctx = "${aci_vrf.vrf01.name}"
}

resource "aci_subnet" "subnet01" {
  parent_dn                           = "${aci_bridge_domain.bd01.id}"
  ip                                  = "10.0.0.1/16"
  scope                               = ["private"]
  description                         = "This subject is created by terraform"
}

# App Profile Definition
resource "aci_application_profile" "app01" {
  tenant_dn  = "${aci_tenant.terraform_tenant.id}"
  name       = "app01"
  name_alias = "demo_ap"
  prio       = "level1"
}


# add vmm dvs
resource "aci_vmm_domain" "vmm_vcenter" {
        provider_profile_dn = var.vmm_vcenter
        description         = "%s"
        name                = "vmm_vcenter"
        
    } 


# EPG Definitions
resource "aci_application_epg" "web" {
  application_profile_dn  = "${aci_application_profile.app01.id}"
  name                    = "web"
  name_alias              = "Nginx"
  relation_fv_rs_cons     = ["${aci_contract.web_to_app.name}", 
                             "${aci_contract.any_to_log.name}"]

  relation_fv_rs_bd       = "${aci_bridge_domain.bd01.name}"
}


resource "aci_epg_to_domain" "web" {

  application_epg_dn    = "${aci_application_epg.web.id}"
  tdn                   = "${aci_vmm_domain.vmm_vcenter.id}"
  binding_type          = "dynamicBinding"
  res_imedcy            = "immediate"
  instr_imedcy          = "immediate"
  vmm_allow_promiscuous = "accept"
  vmm_forged_transmits  = "reject"
  vmm_mac_changes       = "accept"
}

resource "aci_application_epg" "app" {
  application_profile_dn  = "${aci_application_profile.app01.id}"
  name                    = "app"
  name_alias              = "NodeJS"
  relation_fv_rs_prov     = ["${aci_contract.web_to_app.name}"]
  relation_fv_rs_cons     = ["${aci_contract.app_to_db.name}",
                             "${aci_contract.app_to_auth.name}",
                             "${aci_contract.any_to_log.name}"]

  relation_fv_rs_bd       = "${aci_bridge_domain.bd01.name}"
}

resource "aci_application_epg" "db_cache" {
  application_profile_dn  = "${aci_application_profile.app01.id}"
  name                    = "db_cache"
  name_alias              = "DB_Cache"
  relation_fv_rs_prov     = ["${aci_contract.app_to_db.name}"]
  relation_fv_rs_cons     = ["${aci_contract.cache_to_db.name}",
                             "${aci_contract.any_to_log.name}"]

  relation_fv_rs_bd       = "${aci_bridge_domain.bd01.name}"
}
resource "aci_application_epg" "db" {
  application_profile_dn  = "${aci_application_profile.app01.id}"
  name                    = "db"
  name_alias              = "MariaDB"
  relation_fv_rs_prov     = ["${aci_contract.cache_to_db.name}"]
  relation_fv_rs_cons     = ["${aci_contract.any_to_log.name}"]     

  relation_fv_rs_bd       = "${aci_bridge_domain.bd01.name}"
}
resource "aci_application_epg" "log" {
  application_profile_dn  = "${aci_application_profile.app01.id}"
  name                    = "log"
  name_alias              = "Logstash"
  relation_fv_rs_prov     = ["${aci_contract.any_to_log.name}"]

  relation_fv_rs_bd       = "${aci_bridge_domain.bd01.name}"
}
resource "aci_application_epg" "auth" {
  application_profile_dn  = "${aci_application_profile.app01.id}"
  name                    = "auth"
  name_alias              = "Auth"
  relation_fv_rs_prov     = ["${aci_contract.app_to_auth.name}"]
  relation_fv_rs_cons     = ["${aci_contract.any_to_log.name}"]
 
  relation_fv_rs_bd       = "${aci_bridge_domain.bd01.name}"
}

# Contract Definitions
resource "aci_contract" "web_to_app" {
  tenant_dn = "${aci_tenant.terraform_tenant.id}"
  name      = "web_to_app"
  scope     = "tenant"
}

resource "aci_contract" "app_to_db" {
  tenant_dn = "${aci_tenant.terraform_tenant.id}"
  name      = "app_to_db"
  scope     = "tenant"
}

resource "aci_contract" "app_to_auth" {
  tenant_dn = "${aci_tenant.terraform_tenant.id}"
  name      = "app_to_auth"
  scope     = "tenant"
}

resource "aci_contract" "cache_to_db" {
  tenant_dn = "${aci_tenant.terraform_tenant.id}"
  name      = "cache_to_db"
  scope     = "tenant"
}

resource "aci_contract" "any_to_log" {
  tenant_dn = "${aci_tenant.terraform_tenant.id}"
  name      = "any_to_log"
  scope     = "tenant"
}

# Subject Definitions
resource "aci_contract_subject" "only_web_secure_traffic" {
  contract_dn                  = "${aci_contract.web_to_app.id}"
  name                         = "only_web_secure_traffic"
  relation_vz_rs_subj_filt_att = ["${aci_filter.https_traffic.name}"]
}

resource "aci_contract_subject" "only_db_traffic" {
  contract_dn                  = "${aci_contract.app_to_db.id}"
  name                         = "only_db_traffic"
  relation_vz_rs_subj_filt_att = ["${aci_filter.db_traffic.name}"]
}

resource "aci_contract_subject" "only_auth_traffic" {
  contract_dn                  = "${aci_contract.app_to_auth.id}"
  name                         = "only_auth_traffic"
  relation_vz_rs_subj_filt_att = ["${aci_filter.https_traffic.name}"]
}

resource "aci_contract_subject" "only_log_traffic" {
  contract_dn                  = "${aci_contract.any_to_log.id}"
  name                         = "only_log_traffic"
  relation_vz_rs_subj_filt_att = ["${aci_filter.https_traffic.name}"]
}

resource "aci_contract_subject" "only_db_cache_traffic" {
  contract_dn                  = "${aci_contract.cache_to_db.id}"
  name                         = "only_db_cache_traffic"
  relation_vz_rs_subj_filt_att = ["${aci_filter.db_traffic.name}"]
}

# Contract Filters
## HTTPS Traffic
resource "aci_filter" "https_traffic" {
  tenant_dn = "${aci_tenant.terraform_tenant.id}"
  name      = "https_traffic"
}

resource "aci_filter_entry" "https" {
  filter_dn   = "${aci_filter.https_traffic.id}"
  name        = "https"
  ether_t     = "ip"
  prot        = "tcp"
  # Note using `443` here works, but is represented as `https` in the model
  # Using `https` prevents TF trying to set it to `443` every run
  d_from_port = "https"
  d_to_port   = "https"
}
## DB Traffic
resource "aci_filter" "db_traffic" {
  tenant_dn = "${aci_tenant.terraform_tenant.id}"
  name      = "db_traffic"
}

resource "aci_filter_entry" "mariadb" {
  filter_dn   = "${aci_filter.db_traffic.id}"
  name        = "mariadb"
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "3306"
  d_to_port   = "3306"
}
