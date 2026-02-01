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
cp mongo.repo / /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongo Repo" 

dnf install mongodb-org -y 
VALIDATE $? "Installing MongoDB Server" 

systemctl enable mongod 
VALIDATE $? "Enable MongoDB" 

systemctl start mongod
VALIDATE $? "Start MongoDB"

sed -i 's/127.0.0.0/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"
