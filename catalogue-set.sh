#!/bin/bash
set -euo pipefail

trap 'echo "There is an error in $LINENO, Command is: $BASH_COMMAND"' ERR

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.spdevhops.shop
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOGS_FILE

if [ $USERID -ne 0 ]; then
   echo "ERROR::Please run this script with root privelege"
   exit 1
fi



dnf module disable nodejs -y &>>$LOGS_FILE

dnf module enable nodejs:20 -y &>>$LOGS_FILE

dnf install nodejs -y &>>$LOGS_FILE

echo -e "Installing NodeJS 20 ... $G SUCCESS $N"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop

else
   echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 

cd /app

rm -rf /app/*

unzip /tmp/catalogue.zip

npm install &>>$LOGS_FILE

cp $SCRIPT_DIR/catalogue.service  /etc/systemd/system/catalogue.service

systemctl daemon-reload
systemctl enable catalogue &>>$LOGS_FILE
echo -e "Catalogue application setup ... $G SUCCESS $N"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>>$LOGS_FILE

INDEX=$(mongosh mongodb.spdevhops.shop --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
   mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOGS_FILE
   
else
   echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue
echo -e "Loading products and restarting catalogue...$G SUCCESS $N"