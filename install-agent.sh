#!/bin/bash
#!/bin/bash

resourceGroupName=$1
aksName=$2

sudo apt-get update
sudo apt-get install -y ca-certificates curl

# install az-cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash 

az login --identity

# fetch kubectl and kubeconfig of target cluster
az aks install-cli
az aks get-credentials --resource-group $(resourceGroupName) --name $(aksName)

# setup helm 
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sh ./get_helm.sh

VMUserName=$3
curl -o/home/skm.sh https://raw.githubusercontent.com/DiamadisMxD/aget-scipts/main/skm.sh
echo $VMUserName

cd /home/$VMUserName  # VMUserName is VMSS Admin which is different from root user, and can run the config

# define those variable in admin context
AzureDevOpsURL=$4
AzureDevOpsPAT=$5
AgentPoolName=$6

# Creates directory & download ADO agent install files
mkdir myagent && cd myagent

# download the zip for the agent configuration and extract it
wget https://vstsagentpackage.azureedge.net/agent/2.214.1/vsts-agent-linux-x64-2.214.1.tar.gz
tar zxf vsts-agent-linux-x64-2.214.1.tar.gz

chown -R $VMUserName:$VMUserName /home/$VMUserName/myagent

echo "running config.sh"

# must not run as root
su - $VMUserName -c "cd /home/$VMUserName/myagent && ./config.sh --unattended \
  --agent ${AZP_AGENT_NAME:-$(hostname)} \
  --url $AzureDevOpsURL \
  --auth PAT \
  --token $AzureDevOpsPAT \
  --pool $AgentPoolName \
  --replace \
  --acceptTeeEula"

cd /home/$VMUserName/myagent

echo "agent configured start service"

# Install and start the agent service
sudo ./svc.sh install
sudo ./svc.sh start
