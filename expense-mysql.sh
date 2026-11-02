```bash
#!/bin/bash

start_time=$(date +%s)
date_time=$(date "+%F %H:%M:%S")

user_id=$(id -u)
log_folder="/var/log/expense_project"
log_path="$log_folder/expense_project.log"

mkdir -p "$log_folder"
touch "$log_path"

if [ "$user_id" -ne 0 ];
then
    echo "Please run the script with Sudo access..." | tee -a "$log_path"
    exit 1
else
    echo "Thanks for running the script with sudo access, your script will be started in a moment...." | tee -a "$log_path"
fi

echo "=================== Script Started Execution $date_time ====================>" | tee -a "$log_path"

validate(){
    if [ "$1" -eq 0 ];
    then
        echo "$2 ......... is success" | tee -a "$log_path"
    else
        echo "$2 ......... is failed" | tee -a "$log_path"
        exit 1
    fi
}

dnf install mysql-server -y &>> "$log_path"
validate $? "Installing mysql-server"

systemctl enable mysqld &>> "$log_path"
validate $? "Enabling service mysql-server"

systemctl start mysqld &>> "$log_path"
validate $? "Starting service mysql-server"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>> "$log_path"
validate $? "Setting up root password for mysql"

systemctl status mysqld &>> "$log_path"
validate $? "Mysqld service is running"

end_time=$(date +%s)
total_time=$((end_time - start_time))

echo "=================== Script Execution Completed $(date "+%F %H:%M:%S") ====================>" | tee -a "$log_path"

echo "=================== Total time taken: $total_time seconds ====================>" | tee -a "$log_path"