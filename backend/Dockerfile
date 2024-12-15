# Use an official Node.js runtime as a parent image
FROM node:14

# Set the working directory inside the container
WORKDIR /app

# Copy the package.json and package-lock.json files into the container
COPY package*.json ./

# Install dependencies (this will install 'express', 'mongoose', 'cors', etc.)
RUN npm install

# Copy the rest of the application code into the container
COPY . .

# Expose the app port
EXPOSE 3000

# Command to run the application
CMD ["node", "index.js"]
