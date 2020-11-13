#!/bin/bash

# The $DOPPLER_TOKEN environment variable with the Service Token value is required to run this script
# usage: DOPPLER_TOKEN=dp.st.XXXX ./bin/create-secret-service-token.sh

if [ -z ${DOPPLER_TOKEN+x} ]; then echo '[error]: The $DOPPLER_TOKEN environment variable must be set'; exit 1;fi

kubectl create secret generic doppler-token --from-literal=DOPPLER_TOKEN=${DOPPLER_TOKEN}
kubectl describe secret doppler-token
