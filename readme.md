# Full Stack Deployment: Node.js, Docker, NGINX, and AWS

![DevOps Workflow Node.js](https://placehold.co/800x300/3c873a/ffffff?text=Node.js+%E2%86%92+Containerize+%E2%86%92+Deploy+%E2%86%92+Scale)

## 📜 Project Overview

This project demonstrates a complete, end-to-end DevOps workflow for deploying a **Node.js (Express)** web application. The primary objective is to showcase proficiency in containerization with **Docker**, setting up a reverse proxy with **NGINX**, and deploying a scalable, highly-available architecture on **Amazon Web Services (AWS)** using EC2 and an Application Load Balancer (ALB).

### Table of Contents
1.  [**Part 1: Docker Containerization**](#part-1-docker-containerization-🐳)
2.  [**Part 2: NGINX as a Reverse Proxy**](#part-2-nginx-as-a-reverse-proxy-🔄)
3.  [**Part 3: AWS Deployment with Load Balancer**](#part-3-aws-deployment-with-load-balancer-☁️)
4.  [**Video Tutorial**](#video-tutorial-🎥)

---

## Part 1: Docker Containerization 🐳

### Approach
The first step was to containerize the Node.js application using Docker. This approach ensures a consistent and portable environment by bundling the application code, Node.js runtime, and dependencies into a single, isolated container. The `Dockerfile` is optimized for security by creating a non-root user and for efficiency by leveraging Docker's layer caching for `npm install`.

### Deliverables

#### 1. Dockerfile
The following `Dockerfile` defines the steps to build the application image:

```
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
```

#### 2. Docker Hub Image
The resulting Docker image is pushed to Docker Hub and is publicly accessible here:
* **Image Link:** `https://hub.docker.com/repository/docker/eswarsaikumar/rablo/general`

#### 3. Instructions to Run Locally
To build and run this container on your local machine:

1.  **Build the image:**
    ```bash
    docker build -t your-dockerhub-username/your-nodejs-app-name .
    ```
2.  **Run the container:**
    ```bash
    docker run -p 80:80 your-dockerhub-username/your-nodejs-app-name
    ```
3.  **Verify:** Open your browser and navigate to `http://localhost:8080`.

---
<img width="1538" height="521" alt="Screenshot 2025-08-20 073218" src="https://github.com/user-attachments/assets/53236957-9c91-418c-8581-108a5ba1171e" />
<img width="1552" height="398" alt="Screenshot 2025-08-20 073244" src="https://github.com/user-attachments/assets/3cca76c0-8d5f-4e69-ad1f-319efda2f6b9" />
<img width="1881" height="349" alt="Screenshot 2025-08-20 073322" src="https://github.com/user-attachments/assets/d90c550b-c19b-4b70-b739-2343800b8671" />


## Part 2: NGINX as a Reverse Proxy 🔄

### Approach
NGINX was configured as a reverse proxy to manage incoming traffic. This is a best practice for Node.js applications, as NGINX is highly efficient at handling concurrent connections and can also be used for tasks like SSL termination and serving static assets. `docker-compose` orchestrates the Node.js and NGINX containers for a seamless local development experience.

### Deliverables

#### 1. `nginx.conf`
This configuration file instructs NGINX to listen on port 80 and forward all traffic to the Node.js container on its internal port, 80.

```nginx
upstream webapp {
    server app:80;
}

server {
    # NGINX listens on the standard web port 80
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
    # This will build the image from the Dockerfile in the current directory
    build: .
    # You can also use the image from Docker Hub if you prefer
    # image: your-dockerhub-username/your-nodejs-app-name

  nginx:
    image: nginx:1.21-alpine
    ports:
      - "8080:8080"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app
```

#### 3. Instructions to Run
1.  **Start the services:**
    ```bash
    docker compose up
    ```
2.  **Verify:** Open your browser and navigate to `http://localhost`.
   
<img width="1888" height="682" alt="Screenshot 2025-08-20 072352" src="https://github.com/user-attachments/assets/a32bba13-3af8-4064-9de4-ab93191cf1f3" />

<img width="939" height="162" alt="Screenshot 2025-08-20 072414" src="https://github.com/user-attachments/assets/57507578-cf63-409a-b94d-a4d5ce0e4244" />


## Part 3: AWS Deployment with Load Balancer ☁️

### Approach
For a scalable and resilient production environment, the application was deployed to two AWS EC2 instances. An **Application Load Balancer (ALB)** was placed in front of these instances to distribute incoming traffic evenly. The ALB also performs health checks, automatically routing traffic away from any unhealthy instance, thus ensuring high availability.

### Deliverables

#### 1. EC2 and ALB Configuration
* **EC2 Instances:** Two `t2.micro` instances were launched using RHEL-9 AMI. Docker was installed on each instance.
* **Security Groups:** Configured to allow HTTP traffic (port 80) from anywhere and SSH traffic (port 22) from a specific IP for security.
* **Application Load Balancer (ALB):** An internet-facing ALB was configured to listen on port 80.
* **Target Group:** The two EC2 instances were registered in a target group. The ALB forwards requests to this group on port 80 and performs health checks on the `/` endpoint.

#### 2. Screenshots
<img width="1890" height="401" alt="Screenshot 2025-08-19 183754" src="https://github.com/user-attachments/assets/23f17a34-7c1d-4e21-96a4-615c3e71253f" />
<img width="1578" height="680" alt="Screenshot 2025-08-19 183919" src="https://github.com/user-attachments/assets/e570b1e0-4f7a-4fdc-9259-786c19efbfed" />
<img width="1382" height="377" alt="Screenshot 2025-08-19 184530" src="https://github.com/user-attachments/assets/fb8b7409-3949-4c5a-9fd9-1fa10e664a52" />
<img width="1327" height="465" alt="Screenshot 2025-08-19 184745" src="https://github.com/user-attachments/assets/d5a0cd19-2b29-4111-acb4-79f6433cfb5d" />
<img width="1890" height="740" alt="Screenshot 2025-08-19 184843" src="https://github.com/user-attachments/assets/c3153aa3-fb76-4b8a-b1d5-cfd23edc9f5b" />
<img width="1866" height="658" alt="Screenshot 2025-08-20 071611" src="https://github.com/user-attachments/assets/238d1454-7763-4e7e-a885-dac55677ec59" />
<img width="1440" height="127" alt="Screenshot 2025-08-20 071619" src="https://github.com/user-attachments/assets/08625625-e83a-4fe5-834f-3675dcbc2827" />
<img width="880" height="204" alt="Screenshot 2025-08-20 071552" src="https://github.com/user-attachments/assets/c4abd4d7-46cc-44bd-a77a-3d7ba7028d33" />
<img width="1892" height="673" alt="Screenshot 2025-08-20 080659" src="https://github.com/user-attachments/assets/1095747b-ae97-4b51-b887-1f5247310b23" />
<img width="1569" height="450" alt="Screenshot 2025-08-20 080710" src="https://github.com/user-attachments/assets/6d74fe4f-c805-4487-8e87-077b58f7da2d" />
<img width="1579" height="311" alt="Screenshot 2025-08-20 080743" src="https://github.com/user-attachments/assets/7ee58fb5-26f6-4057-9cb7-866f03db6e97" />
<img width="1553" height="417" alt="Screenshot 2025-08-20 080909" src="https://github.com/user-attachments/assets/ec9c95d2-f76e-42b6-ae3c-55608ffa58bb" />
<img width="1574" height="499" alt="Screenshot 2025-08-20 081030" src="https://github.com/user-attachments/assets/cc57595f-6677-4ddd-a5a5-9b5a286f3497" />
<img width="1545" height="453" alt="Screenshot 2025-08-20 081038" src="https://github.com/user-attachments/assets/b1b8b851-8517-4c8c-9278-92b1f6aed3df" />
<img width="928" height="214" alt="Screenshot 2025-08-20 081237" src="https://github.com/user-attachments/assets/cebd9141-8212-4eca-a7f4-f8a9370e2683" />


#### 3. Deployment and Testing
1.  SSH into each EC2 instance and install Docker.
2.  Run the application container on each instance, mapping the instance's port 80 to the container's port 8080:
    ```bash
    docker run -d -p 80:8080 your-dockerhub-username/your-nodejs-app-name
    ```
3.  To test, access the **DNS name** of the Application Load Balancer in a web browser.

## Video Tutorial 🎥

A complete video tutorial was created to walk through the entire process, from setting up the initial GitHub repository to the final, automated deployment on AWS.

* Video Link: [*https://www.loom.com/share/65bc54ac1016490d877e193d255717df?sid=1de8b79b-41bd-4917-9874-32ca7fcbd579*]


