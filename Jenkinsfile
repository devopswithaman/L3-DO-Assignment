pipeline {
    agent any

    environment {
        SCANNER_HOME=tool 'sonar-scanner'

        YOUR_EMAIL_ID = 'devopswithaman@gmail.com'

        AWS_ACCOUNT_ID = credentials('ACCOUNT_ID')
        AWS_ECR_BACKEND_REPO_NAME = credentials('ECR_REPO2')
        AWS_ECR_FRONTFRONT_REPO_NAME = credentials('ECR_REPO1')
        AWS_DEFAULT_REGION = 'us-east-2' //your Region
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/"

        GIT_REPO_NAME = "L3-DO-Assignment"
        GIT_USER_NAME = credentials('GIT_USER_NAME')

        TIMESTAMP = sh(script: 'date "+%Y-%m-%d_%H-%M-%S"', returnStdout: true).trim()
    }


    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/devopswithaman/L3-DO-Assignment.git'
            }
        }

        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=ToDo \
                    -Dsonar.projectKey=ToDO'''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-Token'
                }
            }
        }

        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
         stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }

        stage("Build and Push React Image") {
            steps {
                script {
                    dir('React') {
                        sh "aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin ${REPOSITORY_URI}"
                        buildAndPushDockerImage(AWS_ECR_REACT_REPO_NAME)
                    }
                }
            }
        }


        stage("Build Angular and Push Image") {
            steps {
                script {
                    dir('Angular') {
                        buildAndPushDockerImage(AWS_ECR_ANGULAR_REPO_NAME)
                    }
                }
            }
        }

        stage("Trivy Image Scan"){
            steps{
                sh "trivy image ${REPOSITORY_URI}${AWS_ECR_FRONTFRONT_REPO_NAME}:${TIMESTAMP} > trivyimage.txt"
                 sh "trivy image ${REPOSITORY_URI}${AWS_ECR_BACKEND_REPO_NAME}:${TIMESTAMP} > trivyimage1.txt"                
            }
        }

        stage('Update Deployment file') {
            steps {
                script {
                    dir('k8s_files/Angular') {
                        withCredentials([string(credentialsId: 'GITHUB_TOKEN', variable: 'GITHUB_TOKEN')]) {
                            updateDeploymentFile(AWS_ECR_ANGULAR_REPO_NAME)
                        }
                    }

                    echo "Updating React"

                    dir('k8s_files/React') {
                        withCredentials([string(credentialsId: 'GITHUB_TOKEN', variable: 'GITHUB_TOKEN')]) {
                            updateDeploymentFile(AWS_ECR_REACT_REPO_NAME)
                        }
                    }
                }
            }
        }
    }
}

// Function to build and push Docker image
def buildAndPushDockerImage(imageName) {
        sh "docker build -t ${imageName}:${TIMESTAMP} ."
        sh "docker tag ${imageName}:${TIMESTAMP} " + REPOSITORY_URI + "${imageName}:${TIMESTAMP}"
        sh "docker push ${REPOSITORY_URI}${imageName}:${TIMESTAMP}"
        sh "docker image prune -f"
    }     

// Function to update deployment file
def updateDeploymentFile(repoName) {
        gitConfig()
        sh '''   
            imageTag=$(grep -oP '(?<=registry:)[^ ]+' deployment.yaml)
            sed -i "s/${repoName}:${imageTag}/${repoName}:${TIMESTAMP}/" deployment.yaml
            git add deployment.yaml
            git commit -m "Update deployment Image to version \${TIMESTAMP}"
            git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
        '''
}

// Function for common Git configuration
def gitConfig() {
    sh "git config user.email $YOUR_EMAIL_ID"
    sh "git config user.name 'devopswithaman'"
}
