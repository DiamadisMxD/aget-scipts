#!/bin/bash

az login --identity
#Secret key managment#
ssh-keygen -t rsa -f ~/.ssh/private_key -C agent-cn-app -b 2048

#Update secret key
az keyvault secret set --name vmKey --vault-name kv-cn-app --file ~/.ssh/private_key
