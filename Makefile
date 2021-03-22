# Copyright (c) 2021 Microsoft
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT
RESOURCE_GROUP=rg-bicep-test2
NAME=testbicep
DEPLOYMENT_NAME=main-bicep-deployment
LOCATION=southcentralus

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
		--parameters workspaceName=ws-testbicep-hj2l \
					 ciName=erik-1123b \
					 assignedUserId='b953e707-e89d-41b2-9b4f-7fca80ce7319' \
					 vmSkuName=Standard_DS3_v2 \
					 sshPublicKey='$(shell cat ~/.ssh/id_nbvm_rsa.pub)'

list-deployments:
	az deployment group list -g ${RESOURCE_GROUP}