#!/bin/bash


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
echo "Script start executed at : $(date)" | tee -a $LOGS_FILE

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo "$2 ......FAILURE" | tee -a $LOGS_FILE
        exit1
    else
         echo "$2..... SUCCESS" | tee -a $LOGS_FILE
    fi
}

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y
VALIDATE $? "Installing nodejs 20"


useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "User added"

mkdir /app 
curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading Cart code"

cd /app 
VALIDATE $? "Moving to app directory

unzip /tmp/cart.zip
VALIDATE $? "Unzip Cart code"

npm install &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

systemctl daemon-reload
systemctl enable cart 
systemctl start cart
VALIDATE $? "Starting Cart"


