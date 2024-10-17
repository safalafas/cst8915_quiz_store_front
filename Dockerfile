# Build stage using a slim version of Node.js
FROM node:20-slim as build-stage

# Set the working directory
WORKDIR /app

# Install git (needed only for cloning, you can skip this if you copy code locally)
RUN apt-get update && apt-get install -y git

# Copy package.json and package-lock.json for better layer caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the app for production
RUN npm run build

# Production stage using a slim version of Nginx
FROM nginx:stable-alpine-slim as production-stage

# Copy built assets from the build stage
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Ensure nginx has the correct permissions to serve the files (if needed)
RUN chown -R nginx:nginx /usr/share/nginx/html

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
