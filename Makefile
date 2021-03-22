# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT
RESOURCE_GROUP=rg-test
NAME=amlworkspace
DEPLOYMENT_NAME=aml-deployment
LOCATION=southcentralus

CI_NAME=aml-ci

WS_NAME=$(shell az deployment group show -g ${RG_NAME} --name ${DEPLOYMENT_NAME} -o jsonc --query "properties.outputs.workspaceName.value" -o tsv)

create-group:
	az group create -n ${RESOURCE_GROUP} -l ${LOCATION}

delete-group:
	az group delete -n ${RESOURCE_GROUP}

deploy:
	az deployment group create \
		--name ${DEPLOYMENT_NAME} \
		--mode Incremental \
		--resource-group ${RESOURCE_GROUP} \
		--template-file main.bicep \
		--parameters tags=@tags.json \
		--parameters baseResourceName=${NAME}

validate:
	az deployment group validate \
		--name ${DEPLOYMENT_NAME} \
		--resource-group ${RESOURCE_GROUP} \
		--template-file main.bicep \
		--parameters tags=@tags.json \
		--parameters baseResourceName=${NAME}

deploy-ci:
	az deployment group create \
		--name ${DEPLOYMENT_NAME} \
		--mode Incremental \
		--resource-group ${RESOURCE_GROUP} \
		--template-file components/compute-instance.bicep \
		--parameters tags=@tags.json \
		--parameters vnet=@vnet_details.json \
		--parameters workspaceName=${WS_NAME} \
					 ciName=${CI_NAME} \
					 assignedUserId='$(shell az ad signed-in-user show --query objectId -o tsv)' \
					 vmSkuName=Standard_DS3_v2 \
					 sshPublicKey='$(shell cat ~/.ssh/id_nbvm_rsa.pub)'

list-deployments:
	az deployment group list -g ${RESOURCE_GROUP}