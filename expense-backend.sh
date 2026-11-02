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

sed -i 's/<MYSQL-SERVER-IPADDRESS>/database.expense.anilkumarpatnana.online/g' /home/ec2-user/repos/expense_shell/backend.service &>> "$log_path"
validate $? "Adding database domain name in backend service file to interact with database "


dnf module disable nodejs -y &>> "$log_path"
validate $? "Disabling default module of nodejs "

dnf module enable nodejs:24 -y &>> "$log_path"
validate $? "Enabling nodesjs:24 module"

dnf install nodejs -y &>> "$log_path"
validate $? "Installing nodejs "

node -v | tee -a "$log_path"
validate $? "Verifying nodejs version"

mkdir -p /app &>> "$log_path"
validate $? "Creating app directory "


if cat /etc/passwd | grep "^expense:";
    then
    echo "expense user already created .....SKIPPING " | tee -a "$log_path"
    else
    useradd --system --home /app --shell /sbin/nologin --comment "expense system user" expense &>> "$log_path"
    validate $? "Creating expense user for running backend application"
fi

curl -o /tmp/backend.tar.gz https://raw.githubusercontent.com/daws-92s/expense-documentation/refs/heads/main/artifacts/expense-backend-v5.tar.gz &>> "$log_path"
validate $? "Downloading application code to /tmp directory"

tar -xzf /tmp/backend.tar.gz -C /app &>> "$log_path"
validate $? "Unzipping files to /app directory"

cd /app &>> "$log_path"
validate $? "Moving to /app directory"

npm install &>> "$log_path"
validate $? "Installing nodejs dependencies using npm"

touch /etc/systemd/system/backend.service &>> "$log_path"
validate $? "Creating a backend service file"

echo "Installing Mysql-client for loading database schema"

dnf install mysql -y &>> "$log_path"
validate $? "Installing mysql-server"

mysql -h database.expense.anilkumarpatnana.online -u root -pExpenseApp@1 < /app/schema/backend.sql &>> "$log_path"
validate $? "loading database schema"


systemctl daemon-reload &>> "$log_path"
validate $? "Reloading daemon Systemd"

systemctl enable backend &>> "$log_path"
validate $? "Enabling service backend"

systemctl start backend &>> "$log_path"
validate $? "Starting service backend"


end_time=$(date +%s)
total_time=$((end_time - start_time))

echo "=================== Script Execution Completed $(date "+%F %H:%M:%S") ====================>" | tee -a "$log_path"

echo "=================== Total time taken: $total_time seconds ====================>" | tee -a "$log_path"