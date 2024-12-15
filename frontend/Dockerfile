FROM node:14

WORKDIR /app

# Copy only the package files first (to optimize caching)
COPY package.json package-lock.json ./
RUN npm install

# Copy all other files, including public/index.html
COPY . .

# Expose the default React port
EXPOSE 3000

# Start the React app
CMD ["npm", "start"]
