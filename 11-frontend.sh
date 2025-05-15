# Frontend Installation and Configuration Script
source ./common.sh

# Set the variables
LOG_FILE="/tmp/roboshop.log"
component="frontend"

# Clear old log file
cat /dev/null > "$LOG_FILE"

# Display the start banner
print_start_banner

# Set hostname
hostname

# Install Prerequisite packages
prereq_packages

# Install and Configure Nginx
log_message "Configuring Nginx 1.24..."
dnf module disable nginx -y &>> "$LOG_FILE"
dnf module enable nginx:1.24 -y &>> "$LOG_FILE"
dnf install nginx -y &>> "$LOG_FILE"
check_status "Nginx installation"

# Update Nginx configuration
log_message "Updating Nginx configuration..."
cp configuration-files/nginx.conf /etc/nginx/nginx.conf &>> "$LOG_FILE"
check_status "Nginx configuration update"

# Prepare for frontend deployment
log_message "Removing default content..."
rm -rf /usr/share/nginx/html/* &>> "$LOG_FILE"
check_status "Cleaning default content"

# Download and extract frontend content
log_message "Downloading frontend content..."
curl -L -s -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> "$LOG_FILE"
check_status "Frontend download"

log_message "Extracting frontend content..."
unzip -o /tmp/frontend.zip -d /usr/share/nginx/html &>> "$LOG_FILE"
check_status "Frontend extraction"

# Start Nginx service
log_message "Starting Nginx service..."
systemctl enable nginx &>> "$LOG_FILE"
systemctl restart nginx &>> "$LOG_FILE"
check_status "Nginx service startup"

# Cleanup
rm -f /tmp/frontend.zip

# Display the end banner
print_end_banner