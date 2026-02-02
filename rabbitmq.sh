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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Copy systemctl service"

dnf install rabbitmq-server -y &>>LOGS_FILE
VALIDATE $? "Installing Rabbitmq Server"

systemctl enable rabbitmq-server
systemctl start rabbitmq-server &>>LOGS_FILE
VALIDATE $? "Enabled and Started Rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>>LOGS_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>LOGS_FILE
VALIDATE $? "User Created and given permissions"