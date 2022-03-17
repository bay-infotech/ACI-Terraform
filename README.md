[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/majidstd/ACI-Terraform)

# **IST integration with ACI**



## Infrastructure as Code with Terraform

Cisco Intersight Service for HashiCorp Terraform (IST) addresses the challenge of securely connecting and configuring on-premises and hybrid environments to work with Terraform Cloud Business Tier.
Leveraging Intersight Assist, users can integrate Terraform Cloud Business with Cisco Intersight, enabling secure communication between on-premises data centers and edge locations with the IaC platform. This means users can spend less time managing the end-to-end lifecycle of Terraform Cloud Agents, benefiting from native integration directly within Intersight, including upgrades and the ability to scale as demand grows.

In this example, we cover a how we can use IST to automatically configure Cisco ACI.

We will automate configuration of ACI’s logical constructs i.e. Tenant, Bridge domain, AP, EPG, Contracts, Filters to build a 3 tier application in ACI.

#### Requirements

1. Intersight SaaS platform account with Advantage licenses
2. An Intersight Assist appliance that is connected to your Intersight environment.
3. Terraform Cloud Business Tier Account
4. ACI Fabric
5. GitHub account to host your Terraform code.

Link to GitHub Repo
<https://github.com/bay-infotech/ACI-Terraform.git>

## Steps to Deploy Use Case

##### 1. How to setup TFCB Account in Intersight

Login into your Intersight organization account, Claim Target and select Terraform Cloud:

![intersight_add_tfcb](/assets/intersight_add_tfcb.png)

Then fill out the required information:
Terraform Cloud Organization should be matched with Organization name in Terraform Cloud. Terraform Cloud Username/token will be your Terraform Cloud username and user token:

![tfcb_detail](/assets/tfcb_detail.png)

##### 2. How to claim an agent – e.g managed hosts

After claiming the Terraform Cloud, as you see in the images, claim Terraform Cloud Agent and fill out the required information:

![tfcb_claim_agent](/assets/tfcb_claim_agent.png)

As you can see Intersight Assist already filled out automatically as we already installed the Intersight Assist in our data center.

You should fill out the name, Agent pool and Managed host which in this scenario will be the network the APIC controller belong to.

![tfcb_agent_detail](/assets/tfcb_agent_detail.png)

After this step, you will have the Terraform Cloud Agent is showing connected.

![tfcb_agent_connected](/assets/tfcb_agent_connected.png)

##### 3. Terraform Business Cloud Configuration

Login into your Organization, go to setting, Agents. Make sure you have your agent is connected:

![tfcb_web_agent_connected_to_tf](/assets/tfcb_web_agent_connected_to_tf.png)

This means you agent is ready to accept and execute terraform codes.

##### 4. Creating a workspace in TFC

Go to workspace and create a new workspace for this purpose. We created “aci-terraform-ist”(you can create any workspace name that you like)

![tfcb_workspace_select](/assets/tfcb_workspace_select.png)

##### 5. Selecting IST agent in the workspace

Select the IST agent in the workspace setting to execute the Terraform codes by the agent

![tfcb_workspace_agent_select](/assets/tfcb_workspace_agent_select.png)
![tfcb_workspace_agent_select_2](/assets/tfcb_workspace_agent_select_2.png)

##### 6. Terraform Workspace Variables
Set Terraform variables to use aka APIC host name, APIC username, APIC password etc.
You can see variable is been used in this usecase. you can set yours based on your ACI and VMware virtual switch information.

![tfcb_workspace_variables](/assets/tfcb_workspace_variables_hizucg459.png)

##### 7. Execute Deployment

- For Execute the Terraform codes, connect the GitHub repo where the terraform configuration located. Files with \*.tf extension will be executed by Terraform or a Terraform agent.
  You can check my GitHub repo I used: <https://github.com/majidstd/ACI-Terraform>

- Create a New Terraform plan on Runs section:
  ![tfcb_workspace_queue_plan](/assets/tfcb_workspace_queue_plan.png)

- Terraform will evaluate the codes. If the code is passed, it will show all accepted proposed configuration

![tfcb_workspace_run_plan](/assets/tfcb_workspace_run_plan.png)

## Results

After Confirm and apply, terraform will push the configuration into APIC with all desire configuration:

![tfcb_workspace_result_plan_1](/assets/tfcb_workspace_result_plan_1.png)
![tfcb_workspace_result_plan_2](/assets/tfcb_workspace_result_plan_2.png)
