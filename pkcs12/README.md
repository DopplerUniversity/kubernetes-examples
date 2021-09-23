# Using the Doppler Kubernetes Operator for Managing PKCS12 Certificates

This tutorial will show you how to store and automatically sync PKCS12 certificates from Doppler to Kubernetes using the Doppler Kubernetes Operator.

## Requirements

- [Doppler account](https://dashboard.doppler.com)
- [Doppler CLI](https://docs.doppler.com/docs/cli) installed and authenticated
- Privileged access to a Kubernetes cluster
- An existing PKCS12 certificate

## Installing the Kubernetes Operator

The [Doppler Kubernetes Operator](https://docs.doppler.com/docs/kubernetes-operator) continuously syncs secrets to Kubernetes and can auto-reload deployments when secrets change.

Install the Operator using Helm:

```sh
helm repo add doppler https://helm.doppler.com
helm install --generate-name doppler/doppler-kubernetes-operator
```

Or `kubectl`:

```sh
kubectl apply -f https://github.com/DopplerHQ/kubernetes-operator/releases/latest/download/recommended.yaml
```

Installing the Kubernetes Operator creates the following resources:

- `doppler-operator-system` namespace
- `DopplerSecret` Custom Resource Definition (CRD)
- Service account and RBAC role for the Operator
- Operator Deployment

Visit the [Kubernetes Operator GitHub repository](https://github.com/DopplerHQ/kubernetes-operator) to learn more.

## Importing the PKCS12 Certificate to Doppler

As the PKCS12 certificate is in binary format, it must be base64 encoded before importing to Doppler.

If you haven't yet created a Doppler project, you can use the CLI:

```sh
doppler projects create pkcs12
```

Select the appropriate environment to import the secret to:

```sh
doppler setup --project pkcs12 --config prd
```

Then create the base64 encoded PKCS12 certificate secret:

```sh
doppler secrets set PKCS12_CERT="$(base64 -i doppler.p12)"
```

If your PKCS12 certificate is password-protected, you'll need to add that too:

```sh
doppler secrets set PKCS12_PASS="changeit"
```

## Kubernetes Operator Secrets Sync

A [Doppler Service Token](https://docs.doppler.com/docs/enclave-service-tokens) is required to give the Operator access to the secrets for a specific project and config. It will be stored in a Kubernetes secret that the Operator will then access.

Create the Service Token and inject it as a Kubernetes secret in the `doppler-operator-system` namespace:
 
```sh
kubectl create secret generic doppler-project-pkcs12-token \
  --namespace doppler-operator-system \
  --from-literal=serviceToken=$(doppler configs tokens create kubernetes-operator --plain)
```

Next, we'll create a custom `DopplerSecret` which contains data the Operator uses to manage the Kubernetes secret containing the synced secrets.

Kubernetes secrets are base64 encoded, not for security, but to store binary values such as PKCS12 certificates. But as the PKCS12 certificate is already base64 encoded in Doppler, we'll use the optional `processors:` map, which tells the Operator to skip base64 encoding the `PKCS12_CERT` value. 

Save the file contents as `doppler-secret-pkcs12.yaml`: 

```yaml
apiVersion: secrets.doppler.com/v1alpha1
kind: DopplerSecret
metadata:
  name: doppler-secret-pkcs12 # Name of custom resource 
  namespace: doppler-operator-system
spec:
  tokenSecret:
    name: doppler-project-pkcs12-token # Name of Kubernetes service token secret from previous step
  managedSecret:
    name: doppler-pkcs12  # Name of Kubernetes secret Operator will sync secrets to
    namespace: default # Namespace of the deployment that will use the secret
  processors:
    PKCS12_CERT:
      type: base64 # Instructs the Operator to not base64 encode the secret value again
```
 
Then create the `DopplerSecret` in Kubernetes:

```sh
kubectl apply -f pkcs12-secret.yaml
```
 
You can check the Operator created the Kubernetes synced secret by querying for secrets with the Operator's custom label:

```sh
kubectl describe secrets --selector=secrets.doppler.com/subtype=dopplerSecret
```

The output should be similar to:

```
Name:         doppler-pkcs12
Namespace:    default
Labels:       secrets.doppler.com/subtype=dopplerSecret
Annotations:  secrets.doppler.com/dashboard-link: https://dashboard.doppler.com/workplace/projects/pkcs12/configs/prd
              secrets.doppler.com/processor-version: 07647691b375a71fda056fa16a8adb90a1caa0aea8e8adc3bc6ee7a5b69405a4
              secrets.doppler.com/version: W/"d249692722e5022e9a08b911e4b4f53de7e69d0c6c98df6ddde8c679347a4b47"

Type:  Opaque

Data
====
PKCS12_PASS:          8 bytes
DOPPLER_CONFIG:       3 bytes
DOPPLER_ENVIRONMENT:  3 bytes
DOPPLER_PROJECT:      6 bytes
PKCS12_CERT:          3975 bytes
```

The final step is mounting the certificate inside a container.

## Mount PKCS12 Certificate Inside a Kubernetes Deployment

The below deployment uses the `doppler-pkcs12` managed secret created by the Operator to mount the certificate using a secrets volume and supply the certificate password using the `PKCS12_PASS` environment variable.

The `command` and `args` combine to verify the certificate by extracting its metadata for testing purposes.

Save the file contents as ` pkcs12-deployment.yaml`: 

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: doppler-pkcs12
  annotations:
    secrets.doppler.com/reload: 'true'
spec:
  replicas: 1
  selector:
    matchLabels:
      app: doppler-pkcs12
  template:
    metadata:
        labels:
          app: doppler-pkcs12
    spec:
      containers:
        - name: doppler-pkcs12
          image: alpine
          workingDir: /usr/src/app          
          command:
            - '/bin/sh'          
          args: # Install OpenSSL and verify certificate for testing purposes
            - '-c'
            - 'apk add openssl > /dev/null && 
              openssl pkcs12 -in ./secrets/doppler.p12 -nodes -passin pass:"$PKCS12_PASS" | openssl x509 -noout -text && 
              tail -f /dev/null'          
          env: # Set PKCS12_PASS environment variable needed to decrypt  certificate
            - name: PKCS12_PASS
              valueFrom:
                secretKeyRef:
                  name: doppler-pkcs12  # Operator managed secret
                  key: PKCS12_PASS
          volumeMounts:
            - name: doppler-pkcs12-volume
              readOnly: true
              mountPath: /usr/src/app/secrets
          resources:
            limits:
              memory: '256Mi'
              cpu: '250m'
      volumes:
        - name: doppler-pkcs12-volume
          secret:
            secretName: doppler-pkcs12 # Operator managed secret
            items: 
            - key: PKCS12_CERT # Only select the PKCS12_CERT for mounting
              path: doppler.p12 # Certificate name at mount path
```

Create the deployment in Kubernetes:

```sh
kubectl apply -f  pkcs12-deployment.yaml
```

Then confirm the certificate was verified by viewing the container logs:

```sh
kubectl logs --selector app=doppler-pkcs12 --tail=70
```

## Summary

Awesome work!

Now you know how to store and automatically sync PKCS12 certificates from Doppler to Kubernetes using the Doppler Kubernetes Operator.

Be sure to check out the [Kubernetes Operator documentation](https://docs.doppler.com/docs/kubernetes-operator) and head over to the [Doppler Community Forum](https://community.doppler.com/) if you need help or have any questions.

Originally published on the <a href="https://blog.doppler.com/using-the-doppler-kubernetes-operator-for-managing-pkcs12-certificates" rel="canonical">Doppler blog</a>.
