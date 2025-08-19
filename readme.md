# Full Stack Deployment: Node.js, Docker, NGINX, and AWS

![DevOps Workflow Node.js](https://placehold.co/800x300/3c873a/ffffff?text=Node.js+%E2%86%92+Containerize+%E2%86%92+Deploy+%E2%86%92+Scale)

## 📜 Project Overview

This project demonstrates a complete, end-to-end DevOps workflow for deploying a **Node.js (Express)** web application. The primary objective is to showcase proficiency in containerization with **Docker**, setting up a reverse proxy with **NGINX**, and deploying a scalable, highly-available architecture on **Amazon Web Services (AWS)** using EC2 and an Application Load Balancer (ALB). The entire process is automated using a **CI/CD pipeline** built with GitHub Actions.

### Table of Contents
1.  [**Part 1: Docker Containerization**](#part-1-docker-containerization-🐳)
2.  [**Part 2: NGINX as a Reverse Proxy**](#part-2-nginx-as-a-reverse-proxy-🔄)
3.  [**Part 3: AWS Deployment with Load Balancer**](#part-3-aws-deployment-with-load-balancer-☁️)
4.  [**Bonus: CI/CD Automation Pipeline**](#bonus-cicd-automation-pipeline-🚀)
5.  [**Challenges & Solutions**](#challenges--solutions-🧠)
6.  [**Video Tutorial**](#video-tutorial-🎥)

---

## Part 1: Docker Containerization 🐳

### Approach
The first step was to containerize the Node.js application using Docker. This approach ensures a consistent and portable environment by bundling the application code, Node.js runtime, and dependencies into a single, isolated container. The `Dockerfile` is optimized for security by creating a non-root user and for efficiency by leveraging Docker's layer caching for `npm install`.

### Deliverables

#### 1. Dockerfile
The following `Dockerfile` defines the steps to build the application image:

```dockerfile
FROM node:20-alpine

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Create app directory
WORKDIR /opt/app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Use non-root user
USER appuser

# Expose the application port
EXPOSE 8080

# Run the application
CMD ["npm", "start"]
```

#### 2. Docker Hub Image
The resulting Docker image is pushed to Docker Hub and is publicly accessible here:
* **Image Link:** `https://hub.docker.com/r/your-dockerhub-username/your-nodejs-app-name`
    > **Note:** Replace with your actual Docker Hub username and image name.

#### 3. Instructions to Run Locally
To build and run this container on your local machine:

1.  **Build the image:**
    ```bash
    docker build -t your-dockerhub-username/your-nodejs-app-name .
    ```
2.  **Run the container:**
    ```bash
    docker run -p 8080:8080 your-dockerhub-username/your-nodejs-app-name
    ```
3.  **Verify:** Open your browser and navigate to `http://localhost:8080`.

---

## Part 2: NGINX as a Reverse Proxy 🔄

### Approach
NGINX was configured as a reverse proxy to manage incoming traffic. This is a best practice for Node.js applications, as NGINX is highly efficient at handling concurrent connections and can also be used for tasks like SSL termination and serving static assets. `docker-compose` orchestrates the Node.js and NGINX containers for a seamless local development experience.

### Deliverables

#### 1. `nginx.conf`
This configuration file instructs NGINX to listen on port 80 and forward all traffic to the Node.js container on its internal port, 8080.

```nginx
upstream webapp {
    # 'app:8080' refers to the service named 'app' on its exposed port
    server app:8080;
}

server {
    listen 80;

    location / {
        proxy_pass http://webapp;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### 2. `docker-compose.yml`
This file defines the multi-container setup, linking the NGINX proxy to the Node.js application.

```yaml
version: '3.7'

services:
  app:
    build: .
    # image: your-dockerhub-username/your-nodejs-app-name

  nginx:
    image: nginx:1.21-alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app
```

#### 3. Instructions to Run
1.  **Start the services:**
    ```bash
    docker-compose up
    ```
2.  **Verify:** Open your browser and navigate to `http://localhost`.

---

## Part 3: AWS Deployment with Load Balancer ☁️

### Approach
For a scalable and resilient production environment, the application was deployed to two AWS EC2 instances. An **Application Load Balancer (ALB)** was placed in front of these instances to distribute incoming traffic evenly. The ALB also performs health checks, automatically routing traffic away from any unhealthy instance, thus ensuring high availability.

### Deliverables

#### 1. EC2 and ALB Configuration
* **EC2 Instances:** Two `t2.micro` instances were launched using the Amazon Linux 2 AMI. Docker was installed on each instance.
* **Security Groups:** Configured to allow HTTP traffic (port 80) from anywhere and SSH traffic (port 22) from a specific IP for security.
* **Application Load Balancer (ALB):** An internet-facing ALB was configured to listen on port 80.
* **Target Group:** The two EC2 instances were registered in a target group. The ALB forwards requests to this group on port 80 and performs health checks on the `/` endpoint.

#### 2. Screenshots

[**Screenshot of your AWS ALB Listeners and Target Group Configuration Here**]

[**Screenshot of your two running EC2 Instances Here**]

#### 3. Deployment and Testing
1.  SSH into each EC2 instance and install Docker.
2.  Run the application container on each instance, mapping the instance's port 80 to the container's port 8080:
    ```bash
    docker run -d -p 80:8080 your-dockerhub-username/your-nodejs-app-name
    ```
3.  To test, access the **DNS name** of the Application Load Balancer in a web browser.

---

## Bonus: CI/CD Automation Pipeline 🚀

### Approach
To automate the entire deployment process, a CI/CD pipeline was created using **GitHub Actions**. This pipeline automatically triggers on every push to the `main` branch. It builds a new Docker image, pushes it to Docker Hub, and then deploys the new version to both EC2 instances without any manual intervention.

### Deliverables

#### 1. GitHub Actions Workflow (`.github/workflows/deploy.yml`)

```yaml
name: Build and Deploy Node.js App to EC2

on:
  push:
    branches: [ "main" ]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: your-dockerhub-username/your-nodejs-app-name:latest

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    strategy:
      matrix:
        host: [${{ secrets.EC2_HOST_1 }}, ${{ secrets.EC2_HOST_2 }}]
    steps:
      - name: Deploy to EC2 instance
        uses: appleboy/ssh-action@v0.1.10
        with:
          host: ${{ matrix.host }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            docker pull your-dockerhub-username/your-nodejs-app-name:latest
            docker stop rablo-app-container || true
            docker rm rablo-app-container || true
            docker run -d --name rablo-app-container -p 80:8080 your-dockerhub-username/your-nodejs-app-name:latest
```

#### 2. How the Pipeline Works
1.  **Trigger:** A developer pushes a code change to the `main` branch.
2.  **Build & Push:** GitHub Actions builds the Node.js Docker image and pushes it to Docker Hub.
3.  **Deploy:** The next job SSHs into each EC2 server, pulls the latest image, and restarts the container with the new version, ensuring zero-downtime deployment.

---

## Challenges & Solutions 🧠

1.  **Challenge:** NGINX returning a `502 Bad Gateway` error.
    * **Solution:** This was resolved by using the `depends_on` key in `docker-compose.yml` to ensure the Node.js `app` container starts and is healthy before the `nginx` container starts.

2.  **Challenge:** EC2 instances marked as "unhealthy" by the ALB.
    * **Solution:** The EC2 security group was misconfigured. It was updated to allow incoming traffic on port 80 specifically from the Application Load Balancer's security group, which allows the health checks to pass.

3.  **Challenge:** `npm install` failing within the Docker build.
    * **Solution:** This was traced to a missing `package-lock.json` file. Running `npm install` locally to generate the lock file and committing it to the repository ensured reproducible builds inside the container.

---

## Video Tutorial 🎥

A complete video tutorial was created to walk through the entire process, from setting up the initial GitHub repository to the final, automated deployment on AWS.

* **Video Link:** [**Link to Your Video Tutorial on YouTube/Vimeo Here**]

### Video Outline
* **Intro (0:00):** Project overview and goals.
* **Part 1 (1:30):** Writing the Node.js app and the `Dockerfile`. Building and running locally.
* **Part 2 (5:00):** Configuring NGINX and setting up `docker-compose`.
* **Part 3 (8:45):** Launching EC2 instances, installing Docker, and configuring the AWS Application Load Balancer.
* **Part 4 (15:00):** Setting up the CI/CD pipeline with GitHub Actions, including configuring secrets.
* **Demo (20:00):** Making a code change, pushing to GitHub, and watching the automated deployment happen in real-time.
* **Outro (22:30):** Summary and key takeaways.
