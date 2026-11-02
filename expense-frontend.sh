#!/bin/bash

start_time=$(date +%s)
date_time=$(date "+%F %H:%M:%S")

user_id=$(id -u)
log_folder="/var/log/expense_project"
log_path="$log_folder/expense_project.log"

mkdir -p "$log_folder"
touch "$log_path"

if [ "$user_id" -ne 0 ]; then
    echo "Please run the script with sudo access..." | tee -a "$log_path"
    exit 1
else
    echo "Thanks for running the script with sudo access..." | tee -a "$log_path"
fi

echo "=================== Script Started Execution $date_time ====================" | tee -a "$log_path"

validate() {
    if [ "$1" -eq 0 ]; then
        echo "$2 ......... is success" | tee -a "$log_path"
    else
        echo "$2 ......... is failed" | tee -a "$log_path"
        exit 1
    fi
}

dnf install nginx -y &>> "$log_path"
validate $? "Installing Nginx"

systemctl enable nginx &>> "$log_path"
validate $? "Enabling Nginx"

systemctl start nginx &>> "$log_path"
validate $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>> "$log_path"
validate $? "Removing default Nginx files"

curl -f -o /tmp/frontend.tar.gz \
    https://raw.githubusercontent.com/daws-92s/expense-documentation/refs/heads/main/artifacts/expense-frontend-v5.tar.gz \
    &>> "$log_path"
validate $? "Downloading frontend files"

tar -xzf /tmp/frontend.tar.gz -C /usr/share/nginx/html &>> "$log_path"
validate $? "Extracting frontend files"

sed -i "s/<BACKEND-PRIVATE-IP>/backend.expense.anilkumarpatnana.online/g" /home/ec2-user/repos/expense_shell/expense.conf
validate $? "Updating Nginx configuration"

cp /home/ec2-user/repos/expense_shell/expense.conf /etc/nginx/default.d/expense.conf &>> "$log_path"
validate $? "Copying nginx config file to /etc/nginx/default.d/expense.conf"

nginx -t &>> "$log_path"
validate $? "Testing Nginx configuration"

systemctl restart nginx &>> "$log_path"
validate $? "Restarting Nginx"

end_time=$(date +%s)
total_time=$((end_time - start_time))

echo "=================== Script Execution Completed $(date "+%F %H:%M:%S") ====================" | tee -a "$log_path"
echo "=================== Total time taken: $total_time seconds ====================" | tee -a "$log_path"