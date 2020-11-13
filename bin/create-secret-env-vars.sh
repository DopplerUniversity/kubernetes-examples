#!/bin/bash

# The $DOPPLER_TOKEN environment variable with the Service Token value is required to run this script
# usage: DOPPLER_TOKEN=dp.st.XXXX ./bin/create-secret-env-vars.sh

if [ -z ${DOPPLER_TOKEN+x} ]; then echo '[error]: The $DOPPLER_TOKEN environment variable must be set'; exit 1;fi

doppler secrets download --no-file --format env > secrets.env
kubectl create secret generic doppler-env-vars --from-env-file=secrets.env
rm secrets.env
kubectl describe secret doppler-env-vars
