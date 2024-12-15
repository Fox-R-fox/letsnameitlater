# Stage 1: Build React app
FROM node:14 as build

WORKDIR /app

COPY package*.json ./
RUN npm install --legacy-peer-deps --no-package-lock
COPY . .

RUN npm run build

# Stage 2: Serve React app with Nginx
FROM nginx:alpine

# Copy the build output to Nginx's public folder
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80 for Nginx
EXPOSE 80

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
