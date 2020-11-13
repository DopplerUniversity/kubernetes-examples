#!/bin/bash

# The $DOPPLER_TOKEN environment variable with the Service Token value is required to run this script
# usage: DOPPLER_TOKEN=dp.st.XXXX ./bin/create-secret-dotenv.sh

if [ -z ${DOPPLER_TOKEN+x} ]; then echo '[error]: The $DOPPLER_TOKEN environment variable must be set'; exit 1;fi

kubectl create secret generic doppler-dotenv --from-literal dotenv="$(doppler secrets download --no-file --format env)"
kubectl describe secret doppler-dotenv
