# Heliverse_project

## React-js Setup Instructions

Follow the steps below to set up the React-js application:

## Step 1: Clone the React-js Repository
- 
  ```bash
  git clone https://github.com/Tushar-ops23/React-js.git
  
## Step 2: Install the Nginx web server
- 
  ```bash
  apt update
  apt install nginx

 ## Step 3: Download and execute the NVM installation script  
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
## Step 6: Set Up React-js Application
 - Change the current working directory to the "React-js" folder:
   ```bash
   cd React-js/
 - Run the build script for the React.js application
   ```bash
   npm install react-script
 - Runs the build script for the React.js application.
   ```bash
   npm run build
 - Changes the current working directory to the "build" folder.
   ```bash
   cd build/
 - Copies all files and directories from the "build" folder to the "/var/www/html/" directory.
   ```bash
   cp -r * /var/www/html/

## Step 7: Configure Nginx 
- Changes the current working directory to the "/etc/nginx/sites-available/" directory.
   ```bash
   cd /etc/nginx/sites-available/
 - Edit the configuration file.
   ```bash
   nano default
   ```
   ```bash
    server {
    listen 80;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name tushar.world;
    location / {
        try_files $uri $uri/ /index.html;
       }
     location ~* \.(js|css)$ {
        root /var/www/html; }
    }
    
 - Check the conf. file 
   ```bash
   nginx -t
 - Restart Nginx
   ```bash
   systemtl restart nginx
   ``` 
    





