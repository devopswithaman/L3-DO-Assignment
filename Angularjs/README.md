# Heliverse_project

## Angular-js Setup Instructions

Follow the steps below to set up the Angular-js Application:

## Step 1: Clone the Angular-js Application Repository
- 
  ```bash
  git clone https://github.com/Tushar-ops23/angularjs-application.git
  
## Step 2: Install the Nginx web server
- 
  ```bash
  apt update
  apt install nginx

 ## Step 3: Download and execute the NVM installation.
- Install NVM (Node Version Manager)
  ```bash
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
 
 ## Step 4: Reload Bashrc File
 - Reloads the bashrc file to apply any changes made.
   ```bash
   source ~/.bashrc
 
 ## Step 5: Install Node.js
 - List the available remote Node.js versions:
   ```bash 
   nvm list-remote
 - Installs Node.js version 18.16.0 using NVM.
   ```bash
   nvm install v18.16.0
   
## Step 6: Set Up Angular-js Application
 - Change the current working directory to the "angularjs-application-js" folder:
   ```bash
   cd angularjs-application/
 - Install the Angular CLI globally using npm:
   ```bash
   npm install -g @angular/cli 
 - Runs the build script for the angularjs-application.
   ```bash
   npm run build
 - Changes the current working directory to the "build" folder.
   ```bash
   cd dist/
 - Copy all files and directories from the "dist" folder to the "/var/www/html/dashboard" directory.
   ```bash
   cp -r * /var/www/html/dashboard

## Step 7: Configure Nginx 
- Changes the current working directory to the "/etc/nginx/sites-available/" directory.
   ```bash
   cd /etc/nginx/sites-available/
 - Edit the configuration file.
   ```bash
   nano default
   ```bash
   server {
    listen 80;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name tushar.world;
    location /dashboard {
        try_files $uri $uri/ /dashboard$uri /dashboard$uri/ /dashboard/index.html;}
    location ~* \.(js|css)$ {
        root /var/www/html/dashboard;}
      }
 - Check the conf. file 
   ```bash
   nginx -t
 - Restart Nginx
   ```bash
   systemtl restart nginx
   ``` 
    





