FROM ubuntu

# Add Tini
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-arm64 /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini
ENTRYPOINT ["tini", "--"]

# Install Doppler CLI
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg && \
    curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | apt-key add - && \
    echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | tee /etc/apt/sources.list.d/doppler-cli.list && \
    apt-get update && \
    apt-get -y install doppler

WORKDIR /usr/src/app
COPY start.sh .

# Requires `DOPPLER_TOKEN` environment variable from Kubernetes secret
CMD ["doppler", "run", "--", "./start.sh"]
