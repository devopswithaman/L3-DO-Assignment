# Assignment for DevOps Engineer

## Instructions

- To create a secured infrastructure to deploy the application on cloud through any IAC code preferably terraform including EKS, VPC and other components you can think of.

- Containerize code with Docker , write Dockerfile keeping in mind best practices.

- Automate the deployment by writing secure ci/cd pipeline using DevSecOps methodology and deploy to kubernetes.

- The code containes two application one in angular and other in react, create two dockerfiles one for each and deploy to kubernetes, make sure you attach a domain to your application and 
 use ingress and route to angular appication through /dashboard and react application on root domain. EX example.com and example.com/dashboard.

- Fork this repo and make all the required changes

## NOTE:
- Url should be working while submission.
- Include security in every stage of process.


# Solution:
*******************************************************************************************************************

Remark: Before atrempting below steps, do additional steps present at last of this fine.

*******************************************************************************************************************

Step 1 : Launch Ec2 Instance with Ubnuntu AMI and t2.large type. I have used following terraform file to launch it.
        Path to file - terraform_files/main.tf
        Commands to execute file- 
            Run "terraform init" to initialize the working directory.
            Run "terraform apply -y"

Step 2: Install Required packages (Java, Jenkins, Docker, SonarQube, AWS CLI, kubectl, eksctl, Terraform, Trivy, Helm)
        Install the required packages .sh by SSHing into the EC2 instance.
        Execute script using the following command.
        chmod 777 packages.sh
        ./packages.sh


Step 3: Verify the installation of all packages.
        jenkins --version
        docker --version
        docker ps
        terraform --version
        kubectl version
        aws --version
        trivy --version
        eksctl version

Step 4: Establish a connection between Jenkins and SonarQube.
        Copy the IP address of the EC2 instance and paste it into the browser to access Jenkins. 
            <EC2-ip:8080>
        Now access SonarQube using:
            <EC2-ip:9000>
            It will ask for the default username and password. Enter "admin" in both.

Step 5: Plugin Installation and Setup (Java, Sonar, Node.js, OWASP, Docker)
        Navigate to the Jenkins dashboard.
        Go to "Manage Jenkins" → "Plugins" → "Available Plugins."
        Search for the following plugins:
            Eclipse Temurin Installer
            SonarQube Scanner
            OWASP Dependency-Check
            Docker
            Docker Commons
            Docker Pipeline
            Docker API
            Docker Build Step

Step 6: Configuration of Global tools.
        Navigate to "Manage Jenkins" → "Tools" → "SonarQube Scanner"
        Navigate to "Manage Jenkins" → "Tools" → "Dependency-Check installation"
        Navigate to "Manage Jenkins" → "Tools" → "Docker Installations"
        Click on "Apply and Save."

Step 7: Configure Sonar Server in Manage Jenkins
        Retrieve the Public IP Address of your EC2 Instance. Since SonarQube operates on Port 9000, access it via <Public IP>:9000.
        Visit your SonarQube Server, navigate to Administration → Security → Users, click on Tokens, update the token by assigning it a name, and then generate the token.
        Enter name of token then click on "Generate"
        Copy the token, then go to the Jenkins Dashboard → Manage Jenkins → Credentials → Add Secret Text. The entry should resemble this.
        Now, Navigate to Dashboard → Manage Jenkins → System and Add like the below image.
        Click on "Apply and Save."

        In the Sonarqube Dashboard, also include a quality gate by navigating to Administration → Configuration → Webhooks.
        Click on "Create"
        In URL Section:
        URL: <http://jenkins-public-ip:8080>/sonarqube-webhook/>

Step 8: Setting up secret for pipeline
        Navigate to Jenkins Dashboard → Manage Jenkins → Credentials → Add Credentials → Secret Text
        Add Your AWS Account ID Number. Click on "Create"
        
        Follow the same instructions to set up the following secrets. Create two ECR repositories (either private or public).
            ECR_REPO1: Your React ECR Repository name.
            ECR_REPO2: Your Angularjs ECR Repository name.
            GIT_USER_NAME: Your Git username.
            GITHUB_TOKEN: Your Guthub personal Token

Step 9: k8s_files -> Angular -> deployment.yaml
        Change ECR image id as in format : <your AWS account number>.dkr.ecr.<region>.amazonaws.com/<React ECR Repo Name>:latest

        k8s_files -> React -> deployment.yaml
        Change ECR image id as in format : <your AWS account number>.dkr.ecr.<region>.amazonaws.com/<React ECR Repo Name>:latest

Step 10: Pipeline up to Docker image creation.

        Add Jenkinsfile script in pipeline section of new job.

        Click on "Apply and Save."
        Click on "Build Now"

Step 11: Now see the reports on SonarQube dashboard on <EC2-ip:9000>

When you log in to ECR , you will see a new image is created. Now, CI part has been completed. 

Now it's time for CD. Let's proceed with the EKS and ArgoCD setup.

Step 12: Setup EKS and ArgoCD, Application Load Balancer controller.
        Execute the following command on the Jenkins server.

            eksctl create cluster --name demo-cluster --region us-east-1 --node-type t2.medium --nodes-min 2 --nodes-max 2

            aws eks update-kubeconfig --region us-east-1 --name demo-cluster

            k get nodes
                
Step 13: Next, install Application LoadBalancer controller. on the cluster:
        Run Following command. Don't Forget to update name and region of EKS cluster in below commands.

        curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
        aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json

        eksctl utils associate-iam-oidc-provider --region=us-west-2 --cluster=demo-cluster --approve
        eksctl create iamserviceaccount --cluster=demo-cluster --namespace=kube-system --name=aws-load-balancer-controller --role-name AmazonEKSLoadBalancerControllerRole --attach-policy-arn=arn:aws:iam::<Your AWS Account NO>:policy/AWSLoadBalancerControllerIAMPolicy --approve --region=us-east-1

Step 14: sudo snap install helm --classic
        helm repo add eks https://aws.github.io/eks-charts
        helm repo update eks
        helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=my-cluster --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
        kubectl get deployment -n kube-system aws-load-balancer-controller

If you observe that your aws-load-balancer-controller pod is running, then everything is set up perfectly.

Step 15: Install ArgoCD on the cluster:
            k create namespace argocd
            kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml
        This will deploy the necessary resources. You can check running pods.
            kubectl get pods -n argocd

Step 16: To access ArgoCD in a web browser, we need to configure its service to use a LoadBalancer.
            kubectl patch svc argocd-server -n argocd --type='json' -p='[{"op": "replace", "path": "/spec/type", "value":"LoadBalancer"}]'

Step 17: Get URL of Loadbalancer by following command.
            kubectl get svc argocd-server -n argocd -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"

Open URL on web browser. 
You may encounter a connection is not secure error, but you can click on Advanced and then proceed to open it.
Username is admin and to get password run following command.
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

Step 18: Deploy application on cluster using ArgoCD
        Navigate to the "Settings" in the left panel of the ArgoCD dashboard.
        Click on "Repositories."
        Select "CONNECT REPO USING HTTPS."
        Provide the repository name where your Manifest files are located and click on "CONNECT."
        Verify the connection status; a successful status indicates the repository connection was established.  

        In the "Path" field, specify the location where your Angular manifest files are located, and provide the other necessary details as illustrated in the screenshot below.

        Click on "CREATE." While your Angular application is starting to deploy, we will create an application for the React. Click on "New App."

        Click on "CREATE." While your React application is starting to deploy, we will create an application for the ingress.

        In the Path, provide the location where your Manifest file of ingress are presented.

        Now, check your deployment. Everything should look nice and green in ArgoCD.

Step 19: Get URL of Loadbalancer by running following command.
            k get ing mainlb -n Demo-App -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"

Step 20: Setting up DNS on Route53.

        Navigate to Route53 -> Hosted zones, select the domain name you want to configure. Remember to use the same domain or subdomain name as used in the Ingress manifest file.

        Click on "Create Record."

Step 21: If utilised a subdomain in the Ingress file, please input it as the record name. Choose "A" as the record type and    select "Alias." For the endpoint, choose "Application and Classic Load Balancer." Specify the region, locate your load balancer name, select it, and click on "Create Records."

Step 22: Setting up Monitoring.
         Use the following shell script to install Grafana and Prometheus using Helm charts. The provided script will also set up everything for monitoring. Run the script on the Jenkins server.

Step 23: You can run following command on terminal to get URL of Grafana and Prometheus.
            kubectl get svc stable-kube-prometheus-sta-prometheus -n prometheus -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
        #for grafana url 
            kubectl get svc stable-grafana -n prometheus -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"

To open promethus url in browser you need to attach ":9090/targets" at end of URL.

To open grafana url you might need to wait for a while.
    Enter user name "admin" and password "prom-operator"

Click on "+" on right hand side and then click on import dashboard as shown in below screenshot.

Enter "15661" and click on "Load"

Then choose "prometheus" as source and Click on "Import"

You can import dashboard as per your requirement from this site. grafana.com/grafana/dashboards

---------------------------------------------------------------------------------------------------

***************************************Additional Steps:****************************************************

Move to Angular.js folder 

Follow the steps below to set up the AngularJS Application:

Step 1: Clone the AngularJS Application Repository
    git clone https://github.com/Tushar-ops23/angularjs-application.git

Step 2: Install the Nginx web server
        sudo apt update
        sudo apt install nginx

Step 3: Download and execute the NVM installation script
        Install NVM (Node Version Manager)
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
        
Step 4: Reload the bashrc file to apply any changes made.
            source ~/.bashrc

Step 5: Install Node.js
        List the available remote Node.js versions:
            nvm list-remote
        Install Node.js version 18.16.0 using NVM.
            nvm install v18.16.0

Step 6: Set Up AngularJS Application
        Change the current working directory to the "angularjs-application" folder:
            cd angularjs-application/
        Install the Angular CLI globally using npm:
            npm install -g @angular/cli 
        Run the build script for the AngularJS application.
            npm run build  
        Change the current working directory to the "build" folder.
            cd dist/
        Copy all files and directories from the "dist" folder to the "/var/www/html/dashboard" directory.
            sudo cp -r * /var/www/html/dashboard

Step 7: Configure Nginx
        Change the current working directory to the "/etc/nginx/sites-available/" directory.
            cd /etc/nginx/sites-available/
        Edit the default configuration file.        
            sudo nano default

    Add the following configuration:

        server {
            listen 80;
            root /var/www/html;
            index index.html index.htm index.nginx-debian.html;
            server_name tushar.world;

            location /dashboard {
                try_files $uri $uri/ /dashboard$uri /dashboard$uri/ /dashboard/index.html;
            }

            location ~* \.(js|css)$ {
                root /var/www/html/dashboard;
            }
        }

Step 8: Check the nginx configuration file syntax:
            sudo nginx -t
        Restart Nginx
            sudo systemctl restart nginx

-----------------------------------------

Move to React folder:

Follow the steps below to set up the React Application:

Step 1: Clone the AngularJS Application Repository
            git clone https://github.com/Tushar-ops23/React-js.git

Step 2: Install the Nginx web server
        sudo apt update
        sudo apt install nginx

Step 3: Download and execute the NVM installation script
        Install NVM (Node Version Manager)
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
        
Step 4: Reload the bashrc file to apply any changes made.
            source ~/.bashrc

Step 5: Install Node.js
        List the available remote Node.js versions:
            nvm list-remote
        Install Node.js version 18.16.0 using NVM.
            nvm install v18.16.0

Step 6: Set Up React-js Application
        Change the current working directory to the "angularjs-application" folder:
            cd React-js/
        Install React-scripts:
            npm install react-scripts
        Install project dependencies:
            npm install
        Run the build script for the React.js application.
            npm run build
        Change the current working directory to the "build" folder.
            cd build/
        Copy all files and directories from the "build" folder to the "/var/www/html/" directory.
            sudo cp -r * /var/www/html/

Step 7: Configure Nginx
        Change the current working directory to the "/etc/nginx/sites-available/" directory.
            cd /etc/nginx/sites-available/
        Edit the default configuration file.        
            sudo nano default

    Add the following configuration:

        server {
            listen 80;
            root /var/www/html;
            index index.html index.htm index.nginx-debian.html;
            server_name tushar.world;

            location / {
                try_files $uri $uri/ /index.html;
            }

            location ~* \.(js|css)$ {
                root /var/www/html;
            }
        }


Step 8: Check the nginx configuration file syntax:
            sudo nginx -t
        Restart Nginx
            sudo systemctl restart nginx

-----------------------------------------------------------------------------

Remark: Please give me one chance, I will take full ownership of my work as deliver the task on time. Hoping to connect you soon and will work together.
