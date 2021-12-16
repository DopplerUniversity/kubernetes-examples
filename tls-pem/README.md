# Using Doppler for Managing Kubernetes TLS/SSL Certificates Secrets in PEM Format

This tutorial will show you how to sync TLS secrets in PEM format from Doppler to Kubernetes using the Doppler CLI and `kubectl`.

## Requirements

- [Doppler CLI](https://docs.doppler.com/docs/cli) installed and authenticated
- Access to a Kubernetes cluster

To follow along with this tutorial, click on the **Import to Doppler** button below to create the Doppler project containing the required variables, including the TLS certificate and key.

[![Import to Doppler](https://raw.githubusercontent.com/DopplerUniversity/app-config-templates/main/doppler-button.svg)](https://dashboard.doppler.com/workplace/template/import?template=https://github.com/DopplerUniversity/kubernetes-examples/blob/master/tls-pem/doppler-template.yaml')

## Creating the TLS Certificate and Key Secrets in Doppler

You can either use the Doppler dashboard to copy and paste in the contents of your certificate and key, or the Doppler CLI as per below:

```sh
doppler secrets set TLS_CERT="$(cat ./tls.cert)"
doppler secrets set TLS_KEY="$(cat ./tls.key)"
```

We recommend using the Doppler CLI to prevent accidental typos from occuring.

In any case, you can use the OpenSSL CLI to verify that the TLS certificate and secret values are valid by extracting the public key from both:

```sh
# Verify key
doppler secrets get TLS_KEY --plain | openssl rsa -pubout

# Verify certificate
doppler secrets get TLS_CERT --plain | openssl x509  -noout -pubkey
```

## Doppler Sync to a Kubernetes TLS Secret

Now that your TLS certificate and key are in Doppler, the next step is syncing them to a Kubernetes secret using the Doppler CLI.

We recommend using Kubernetes' built-in [TLS Secret type](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets) type as it standardizes the property names inside the secret to `tls.crt` and `tls.key`:

```sh
kubectl create secret tls doppler-tls-pem \
  --cert <(doppler secrets get TLS_CERT --plain) \
  --key <(doppler secrets get TLS_KEY --plain)
```
We can see this by describing the secret:

```sh
-> kubectl describe secret doppler-tls-pem

Name:         doppler-tls-pem
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/tls

Data
====
tls.crt:  1545 bytes
tls.key:  1704 bytes
```

## Mount TLS Certificate and Key inside a Kubernetes Deployment

The below deployment mounts the TLS certificate and key inside a container. The `command` here is just for testing purposes to verify the certificate's validity using the OpenSSL CLI to print the certificate's metadata.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: doppler-tls-pem
spec:
  replicas: 1
  selector:
    matchLabels:
      app: doppler-tls-pem
  template:
    metadata:
      labels:
        app: doppler-tls-pem
    spec:
      containers:
        - name: doppler-tls-pem
          image: alpine
          workingDir: /usr/src/app
          command:
            - '/bin/sh'
          args: # Verify certificate
            - '-c'
            - 'apk add openssl > /dev/null && 
              openssl x509 -in secrets/tls.crt -inform pem -noout -text &&
              tail -f /dev/null'
          volumeMounts:
            - name: doppler-tls-pem-volume
              readOnly: true
              mountPath: /usr/src/app/secrets
          resources:
            limits:
              memory: '256Mi'
              cpu: '250m'
      volumes:
        - name: doppler-tls-pem-volume
          secret:
            secretName: doppler-tls-pem
```

As the `mountPath` is set to `/usr/src/app/secrets`, the path to the certificate and key will be:

- `/usr/src/app/secrets/tls.crt`
- `/usr/src/app/secrets/tls.key`


## Enable Automatic Secrets Sync with our Kubernetes Operator

While the Doppler CLI makes it easy to sync TLS secrets, it's only drawback is having to manually sync updates to the TLS secrets in Kubernetes when they're updated in Doppler.

We recommend leveling up to use our [Kubernetes Operator](https://docs.doppler.com/docs/kubernetes-operator) which instantly syncs secrets to Kubernetes when changed and includes support for auto-reloading of deployments when secrets are updated inside the cluster.

Learn more by checking out the [Kubernetes Operator repository](https://github.com/DopplerHQ/kubernetes-operator) on GitHub.

## Summary

Awesome work! Now you know how to use Doppler to simplify and securely manage TLS secrets in PEM format for your Kubernetes hosted applications.

Be sure to check out our [Kubernetes documentation](https://docs.doppler.com/docs/kubernetes) and reach out in our [Doppler Community Forum](https://community.doppler.com/) if you need help.

Originally published on the <a href="https://www.doppler.com/blog/kubernetes-tls-pem-certificates" rel="canonical">Doppler blog</a>.