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
MYSQL_HOST=mysql.devopspro.online

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

dnf install maven -y
VALIDATE $? "Installing Maven"

id roboshop &>>LOGS_FILE
if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "User added"
else
    echo -e "user already exist....$Y SKIPPING $N"
fi 

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOGS_FILE
VALIDATE $? "Downloading User application"

cd /app 
VALIDATE $? "changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/shipping.zip
VALIDATE $? "Unzip User code"

cd /app 
mvn clean package &>>$LOGS_FILE
VALIDATE $? "Installing and Building shipping"

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "Moving and Renaming shipping"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copy systemctl service"

dnf install mysql -y 
VALIDATE $? "Installing Mysql"


mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'

if [$? -ne 0]; then 

    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql 
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql
else
    echo -e "data is already loaded ... $Y SKIPPING $N"

systemctl enable shipping 
systemctl start shipping
VALIDATE $? "Starting Shipping"