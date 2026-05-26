# Node base image
FROM node:18-alpine

# Environment variables (NO SECRETS HERE)
ENV DOMAIN="http://localhost:3000" \
PORT=3000 \
STATIC_DIR="./client"

# Working directory
WORKDIR /usr/src/app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy app source code
COPY . .

# Expose port
EXPOSE 3000

# Start app
CMD ["node", "server.js"]
