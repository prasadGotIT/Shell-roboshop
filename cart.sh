#!/bin/bash
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

VALIDATE(){
         
         if [ $1 -ne 0 ]; then
            echo -e "$2...$R FAILURE $N" | tee -a $LOGS_FILE
            exit 1
        else
            echo -e "$2...$G SUCCESS $N" | tee -a $LOGS_FILE
        fi

}

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disable nodejs"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "Installing NodeJS"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "Creating system user"
else
   echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip 
VALIDATE $? "Download cart"

cd /app
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/cart.zip
VALIDATE $? "unzip cart"

npm install &>>$LOGS_FILE
VALIDATE $? "Install dependencies"

cp $SCRIPT_DIR/cart.service  /etc/systemd/system/cart.service
VALIDATE $? "copy systemctl service"

systemctl daemon-reload
systemctl enable cart &>>$LOGS_FILE
VALIDATE $? "Enable cart"

systemctl restart cart &>>$LOGS_FILE
VALIDATE $? "Restarted cart"