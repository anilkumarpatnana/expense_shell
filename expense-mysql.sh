#!/bin/bash

user_id=$(id -u)
log_path="/var/log/expense_project/expense_project.log"
date_time=$(date "+%F %H %M %S")
start_time=$(date +%s)
total_time=$((end_time - start_time))

if [ "$user_id" -ne 0 ];
then
echo "Please run the script with Sudo access..." | tee -a "$log_path"
exit 1
else
echo "Thanks for running the script with sudo access, you script will be started in a moment...." | tee -a "$log_path"
fi

echo "=================== Script Started Execution $date_time ====================>"

mkdir -p /var/log/expense_project | tee -a "$log_path"
touch  /var/log/expense_project.log | tee -a "$log_path"


validate(){
    if [ "$1" -eq 0 ];
     then
      echo "$2 ......... is success" | tee -a "$log_path"
     else
      echo "$2 ......... is failed"  | tee -a "$log_path"
    fi 
}


dnf install mysql-server -y &>> "$log_path"
validate $? "Installing mysql-server "

systemctl enable mysqld &>> "$log_path"
validate $? "Enabling service mysql-server "

systemctl start mysqld &>> "$log_path"
validate $? "Starting service mysql-server "

mysql_secure_installation --set-root-pass ExpenseApp@1 &>> "$log_path"
validate $? "Setting up root password for mysql "

systemctl status mysqld &>> "$log_path"
validate $? "Mysqld service is running  "

echo "=================== Script Execution Completed $date_time ====================>"
end_time=$(date +%s)
echo "=================== Total time taken to complete $total_time ====================>"


