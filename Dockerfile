FROM node:20-alpine

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Create app directory
WORKDIR /opt/app

# Copy files
COPY . .

# Install dependencies
RUN npm install

# Use non-root user
USER appuser

# Expose port
EXPOSE 8080

# Run app
CMD ["npm", "start"]
