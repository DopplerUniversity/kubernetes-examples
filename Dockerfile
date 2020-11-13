FROM node:lts-alpine

# Install the Doppler CLI
RUN (curl -Ls https://cli.doppler.com/install.sh || wget -qO- https://cli.doppler.com/install.sh) | sh

WORKDIR /usr/src/app

COPY package.json package-lock.json ./
RUN npm clean-install --only=production --silent --no-audit
COPY config.js .

USER node

ENTRYPOINT ["doppler", "run", "--"]
CMD ["npm", "start"]
