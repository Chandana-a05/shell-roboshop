#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop1"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
y="\e[33m"
B="\e[34m"
N="\e[0m" #Normal

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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disabling Nodejs Default version" 

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enable Nodejs 20" 

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Install Nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne o ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "Creating System User"
else
    echo  -e "Roboshop user already exits...$Y SKIPPING $N"
fi
mkdir -p /app 
VALIDATE $? "Creating app Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading catalogue code"

#cd /app

#unzip /tmp/catalogue.zip

#npm install 