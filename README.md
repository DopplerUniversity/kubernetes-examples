# Kubernetes Secrets Management using Doppler

## Setup

- Create [Doppler Service Token](https://docs.doppler.com/docs/enclave-service-tokens)

# Notes

- To keep things simple, a Kubernetes secret is used for all config, instead of splitting between ConfigMap and Secret

## Presumptions

- Familiar with deploying applications on Kubernetes
- Understanding using Kubernetes serets for application configuration

## Doppler secrets management for Kubernetes

- Map secrets from Doppler as enviroment vars
- Mount a .env file or other config file
- Use `doppler run` to dynamically fetch secrets at container runtime