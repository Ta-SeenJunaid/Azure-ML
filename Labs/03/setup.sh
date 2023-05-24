#! /usr/bin/sh

# Set the necessary variables
RESOURCE_GROUP="rg-dp100-labs"
RESOURCE_PROVIDER="Microsoft.MachineLearning"
REGIONS=("eastus" "westus" "centralus" "northeurope" "westeurope" "southeastasia")
RANDOM_REGION=${REGIONS[$RANDOM % ${#REGIONS[@]}]}
WORKSPACE_NAME="mlw-dp100-labs"

# Register the Azure Machine Learning resource provider in the subscription
echo "Register the Machine Learning resource provider:"
az provider register --namespace $RESOURCE_PROVIDER

# Delete the resource group if it already exists to avoid clashes
echo "Delete the resource group" $RESOURCE_GROUP "to avoid clashes:"
az group delete --name $RESOURCE_GROUP

# Create the resource group and workspace and set to default
echo "Create a resource group and set as default:"
az group create --name $RESOURCE_GROUP --location $RANDOM_REGION
az configure --defaults group=$RESOURCE_GROUP

echo "Create an Azure Machine Learning workspace:"
az ml workspace create --name $WORKSPACE_NAME 
az configure --defaults workspace=$WORKSPACE_NAME 

# Create compute instance
guid=$(cat /proc/sys/kernel/random/uuid)
suffix=${guid//[-]/}
suffix=${suffix:0:18}

ComputeName="ci${suffix}"

echo "Creating a compute instance with name: " $ComputeName
az ml compute create --name ${ComputeName} --size STANDARD_DS11_V2 --type ComputeInstance 

# Create compute cluster
echo "Creating a compute cluster with name: aml-cluster"
az ml compute create --name "aml-cluster" --size STANDARD_DS11_V2 --max-instances 2 --type AmlCompute 