#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.daws86s.fun
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log
MYSQL_HOST=mysql.spdevhops.shop

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "Python installing"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
VALIDATE $? "User adding"
else
echo -e "User already exist..$Y Skipping $N "
fi
mkdir -p /app
VALIDATE $? "Creating app directory" 

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "download payment"

cd /app
VALIDATE $? "move to app dirctory"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzip payment code"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "installing dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE

systemctl daemon-reload 
VALIDATE $? "daemon reload"

systemctl enable payment  &>>$LOG_FILE
VALIDATE $? "enable payment"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "start payment"
