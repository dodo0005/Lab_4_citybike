
# ==========================================
# STAGE 1: BUILD
# ==========================================
FROM node:20 AS build

WORKDIR /app

# Accept Git commit SHA as a build argument
ARG GITHUB_SHA=local-dev
ENV GITHUB_SHA=${GITHUB_SHA}

# Copy package files first for Docker caching
COPY package.json package-lock.json ./

# Install ALL dependencies, including devDependencies
RUN npm ci

# Copy application source
COPY . .

# Build application and generate manifest
RUN npm run build


# ==========================================
# STAGE 2: RUNTIME
# ==========================================
FROM node:20-alpine AS runtime

WORKDIR /app

# Copy only the files required to run the application
COPY --from=build /app/server.js ./server.js
COPY --from=build /app/public ./public
COPY --from=build /app/dist/build-manifest.json ./dist/build-manifest.json

# Run as non-root user
USER node

EXPOSE 4173

CMD ["node", "server.js"]
