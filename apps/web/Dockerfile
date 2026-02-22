FROM node:20-alpine

# Native build tools needed by some npm packages (node-sass, etc.)
RUN apk add --no-cache python3 make g++

WORKDIR /workspace

# Copy package files for install
COPY package.json package-lock.json* ./
COPY apps/web/package.json apps/web/

# Install dependencies
RUN npm install --workspace=apps/web

WORKDIR /workspace/apps/web

EXPOSE 8080

# webpack-dev-server needs to bind to 0.0.0.0 to be accessible outside container
CMD ["npx", "webpack", "serve", "--config", "webpack.development.js", "--host", "0.0.0.0"]
