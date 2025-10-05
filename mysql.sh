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

dnf install mysql-server -y &>>LOGS_FILE
VALIDATE $? "mysql installation"
systemctl enable mysqld &>>LOGS_FILE
VALIDATE $? "Enabling mysql"
systemctl start mysqld  &>>LOGS_FILE
VALIDATE $? "Starting mysql"
mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "setting up root password"  

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME))
echo -e "Script executed in: $Y $TOTAL_TIME seconds $N"