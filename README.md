To create a secured infrastructure to deploy the application on cloud through any IAC code preferably terraform including EKS, VPC and other components you can think of.
Containerize code with Docker , write Dockerfile keeping in mind best practices.
Automate the deployment by writing secure ci/cd pipeline using DevSecOps methodology and deploy to kubernetes.
The code containes two application one in angular and other in react, create two dockerfiles one for each and deploy to kubernetes, make sure you attach a domain to your application and use ingress and route to angular appication through /dashboard and react application on root domain. EX example.com and example.com/dashboard.
Fork this repo and make all the required changes

NOTE: Url should be working while submission
Include security in every stage of process.