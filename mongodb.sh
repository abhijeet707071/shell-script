# MongoDB Installation and Configuration Script
source ./common.sh

LOG_FILE="/tmp/roboshop.log"
component="mongodb"


# Clear log file
> "$LOG_FILE"

# Install and Configure Nginx
log_message "Configuring MongoDB repository..." | tee -a "$LOG_FILE"
cp mongo.repo /etc/yum.repos.d/mongo.repo &>> "$LOG_FILE"
check_status "Repo Configuration"

# Install MongoDB
log_message "Installing MongoDB..." | tee -a "$LOG_FILE"
dnf install mongodb-org -y &>> "$LOG_FILE"
dnf install bash-completion -y &>> "$LOG_FILE"
check_status "MongoDB installation"

# Update MongoDB configuration
log_message "Updating MongoDB configuration..." | tee -a "$LOG_FILE"
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/g' /etc/mongod.conf &>> "$LOG_FILE"
check_status "MongoDB configuration update"

# Restart MongoDB service
log_message "Restarting MongoDB service..." | tee -a "$LOG_FILE"
systemctl enable mongod &>> "$LOG_FILE"
systemctl restart mongod &>> "$LOG_FILE"
check_status "MongoDB service restart"

log_message "MongoDB installation completed successfully!"