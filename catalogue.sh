# Catalogue Installation and Configuration Script
source ./common.sh

LOG_FILE="/tmp/roboshop.log"
component="catalogue"

# Clear log file
> "$LOG_FILE"

# Install and NodeJS.
log_message "Installing NodeJS 20..." | tee -a "$LOG_FILE"
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs bash-completion  -y
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
log_message "Removing Old Application Dir..." | tee -a "$LOG_FILE"
if [ -d /app ]; then
  rm -rf /app &>> "$LOG_FILE"
else
  echo -e "\e[32mDirectory '/app' does not exist.\e[0m"
fi
check_status "Remove Old App Dir"


log_message "Creating application dir..." | tee -a "$LOG_FILE"
mkdir /app
check_status "App directory creation"


log_message "Downloading application content..." | tee -a "$LOG_FILE"
curl -L -s -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
check_status "App Content Download"


log_message "Extract App content..." | tee -a "$LOG_FILE"
unzip -o /tmp/catalogue.zip -d /app
check_status "App Content Extraction"


log_message "Install application dependency..." | tee -a "$LOG_FILE"
npm install -C /app &>> "$LOG_FILE"
check_status "App Dependency Installation"


log_message "Creating application service file..." | tee -a "$LOG_FILE"
cp catalogue.service /etc/systemd/system/catalogue.service
check_status "Service file creation"


log_message "Start the Application ..." | tee -a "$LOG_FILE"
systemctl daemon-reload
systemctl enable catalogue
systemctl restart catalogue
check_status "Service start"


log_message "Load the schema..." | tee -a "$LOG_FILE"
cp mongo.repo /etc/yum.repos.d/mongo.repo &>> "$LOG_FILE"
dnf install mongodb-mongosh -y
mongosh --host 172.31.26.6 </app/db/master-data.js
check_status "Schema Load"

log_message "Catalogue installation completed successfully!"





