#!/bin/bash
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop1"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m" #Normal
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.devopspro.online

if [ $USERID -ne 0 ]; then
    echo -e "$R please run this script with root user access $N" | tee -a $LOGS_FILE
    exit 1
fi  
mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo "$2 ......FAILURE" | tee -a $LOGS_FILE
        exit1
    else
         echo "$2..... SUCCESS" | tee -a $LOGS_FILE
    fi
}

dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "Disabling Nginx Default version" 

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? "Enable Nginx 1.24" 

dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Install Nginx"

systemctl enable nginx 
systemctl start nginx
VALIDATE $? "Starting nginx service"


rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove the default content"


curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading frontend content"

cd /usr/share/nginx/html 
VALIDATE $? "moving to user directory"

unzip /tmp/frontend.zip
VALIDATE $? "unzip frontend content"


cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Nginx Reverse Proxy Configuration to reach backend services"

systemctl restart nginx 
VALIDATE $? "Restarting nginx"