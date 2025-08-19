pipeline {
    agent any

    environment {
        IMAGE_NAME = 'eswarsaikumar/expense-simpletimeservice'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials' 
        AWS_CREDENTIALS_ID = 'aws-credentials'
        AWS_REGION = 'us-east-1'
        ECR_REPO_NAME = 'expense-simpletimeservice'
    }
   
    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/eswar-sai-kumar/particle41.git', 
                    credentialsId: 'github-credentials'
            }
        }


        stage('Install Dependencies') {
            steps {
                sh """
                    cd app
                    npm install
                """
            }
        }

        stage('Run Tests') {
            steps {
                echo 'No tests configured - skipping'
                // You can add unit tests here if needed
            }
        }


        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}", "app")
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS_ID}") {
                        docker.image("${IMAGE_NAME}").push()
                    }
                }
            }
        }
        stage('Push to Amazon ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: "${AWS_CREDENTIALS_ID}"]]) {
                        def accountId = sh(script: "aws sts get-caller-identity --query Account --output text", returnStdout: true).trim()
                        def ecrUrl = "${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"

                        sh """
                            aws ecr get-login-password --region ${AWS_REGION} | \
                            docker login --username AWS --password-stdin ${ecrUrl}

                            docker tag ${IMAGE_NAME} ${ecrUrl}
                            docker push ${ecrUrl}

                            echo "Running the Docker container from ECR image..."
                            docker run -d -p 8081:8080 ${ecrUrl}
                        """
                    }
                }
            }
        }

    }

        post {
            success {
                echo 'Build and Push completed successfully!'
            }
            failure {
                echo 'Something went wrong!'
            }
        }
    
}
