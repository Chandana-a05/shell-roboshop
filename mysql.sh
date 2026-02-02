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

dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "Installing Mysql"

systemctl enable mysqld
systemctl start mysqld  &>>$LOGS_FILE
VALIDATE $? "Starting Mysql"

mysql_secure_installation --set-root-pass RoboShop@1
