# Use a Node.js image as the base for building the application
FROM node:22-alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json, package-lock.json, and patches
COPY package.json package-lock.json ./
COPY patches ./patches

# Install dependencies and apply patches
RUN npm install --ignore-scripts && npx patch-package

# Copy the rest of the application source code
COPY . .

# Build the application using TypeScript
RUN npm run build

# Use a smaller Node.js image for the final image
FROM node:22-slim AS release

# Set the working directory inside the container
WORKDIR /app

# Copy the built application and patched node_modules from the builder stage
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/package.json /app/package.json

# Specify the command to run the application
ENTRYPOINT ["node", "dist/index.js"]
