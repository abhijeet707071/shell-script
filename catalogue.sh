# Catalogue Installation and Configuration Script
source ./common.sh

LOG_FILE="/tmp/roboshop.log"
component="catalogue"

# Clear log file
> "$LOG_FILE"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> "$LOG_FILE"

# Install and NodeJS.
log_message "Installing NodeJS 20..." | tee -a "$LOG_FILE"
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs bash-completion mongodb-mongosh -y
check_status "NodeJS installation"

# Create application user
log_message "Creating application user..." | tee -a "$LOG_FILE"
if id roboshop &>/dev/null; then
    echo -e "\e[32mUser 'roboshop' already exists.\e[0m"
else
    useradd -m roboshop &>> "$LOG_FILE"
    check_status "User creation"
fi

# Download and extract catalogue content
rm -rf /app
mkdir /app
curl -L -s -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
unzip -o /tmp/catalogue.zip -d /app


npm install -C /app

cp catalogue.service /etc/systemd/system/catalogue.service

systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue

mongosh --host 172.31.26.6 </app/db/master-data.js

log_message "Catalogue installation completed successfully!"





