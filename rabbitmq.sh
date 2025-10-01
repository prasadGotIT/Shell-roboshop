#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1)
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD
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

cp $SCRIPT_DIR/rabbitmq.repo  /etc/yum.repos.d/rabbitmq.repo &>>LOGS_FILE
VALIDATE $? "Adding rabbitmq repo"

dnf install rabbitmq-server -y &>>LOGS_FILE
VALIDATE $? "rabbitmq installation"
systemctl enable rabbitmq-server &>>LOGS_FILE
VALIDATE $? "Enabling rabbitmq server"
systemctl start rabbitmq-server &>>LOGS_FILE
VALIDATE $? "Starting rabbitmq-server"
rabbitmqctl add_user roboshop roboshop123 &>>LOGS_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>LOGS_FILE
VALIDATE $? "setting up permissions"



END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME))
echo -e "Script executed in: $Y $TOTAL_TIME seconds $N"