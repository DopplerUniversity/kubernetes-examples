# Kubernetes Doppler Integration Examples

![Kubernetes Doppler Integration](https://repository-images.githubusercontent.com/312504996/878e5bd6-01b3-4a2d-bd70-c595122f1f3c)

Doppler is the easiest way to supply secrets to your Kubernetes hosted applications. This repository contains complete working examples for testing and educational purposes.

* [Doppler CLI method](./doppler-cli)  
Uses the Doppler CLI installed in your Docker image to inject secrets as environment variables into your application.

* [Sync TLS Certificates in PEM format](./tls-pem)  
Uses the Doppler CLI and `kubectl` to sync TLS secrets in PEM format.

* [Sync PKCS12 Certificates](./pkcs12)  
Use the Kubernetes Operator to sync PKCS12 certificates.

Check out our [Kubernetes Doppler integration docs](https://docs.doppler.com/docs/kubernetes) to learn more.
