FROM node:lts-alpine

# Update to perform a cache bust
ENV LAST_UPDATED=2020-11-16

# Install the Doppler CLI
RUN (curl -Ls https://cli.doppler.com/install.sh || wget -qO- https://cli.doppler.com/install.sh) | sh

WORKDIR /usr/src/app

COPY package.json package-lock.json ./
RUN npm clean-install --only=production --silent --no-audit
COPY config.js .

USER node

ENTRYPOINT ["doppler", "run", "--"]
CMD ["npm", "start"]
