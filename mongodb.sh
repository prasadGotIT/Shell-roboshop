#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
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

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-org -y &>>LOGS_FILE
VALIDATE $? "Mongodb Installation"

systemctl enable mongod &>>LOGS_FILE
VALIDATE $? "Enable Mongodb"

systemctl start mongod &>>LOGS_FILE
VALIDATE $? "Start Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to MondoDB"

systemctl restart mongod
VALIDATE $? "Restarted MongoDB"
