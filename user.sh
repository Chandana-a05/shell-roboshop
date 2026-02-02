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
echo "Script start executed at : $(date)" | tee -a $LOGS_FILE

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y
VALIDATE $? "Installing Nodejs 20"

id roboshop &>>LOGS_FILE
if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "User added"
else
    echo -e "user already exist....$Y SKIPPING $N"
fi 

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading User application"

cd /app 
VALIDATE $? "changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/user.zip
VALIDATE $? "Unzip User code"

npm install &>>$LOGS_FILE
VALIDATE $? "Installing dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copy systemctl service"

systemctl daemon-reload
systemctl enable user 
systemctl start user
VALIDATE $? "Starting user"







