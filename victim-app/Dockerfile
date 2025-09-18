# Use a base Node.js image
FROM node:18-alpine

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json .

# Install dependencies. This is the vulnerable step.
RUN npm install

# Copy the rest of the app's source code
COPY . .

# Expose the port
EXPOSE 3000

# Run the application
CMD ["node", "index.js"]