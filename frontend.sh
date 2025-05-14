# Frontend Installation and Configuration Script
source ./common.sh

LOG_FILE="/tmp/roboshop.log"
component="frontend"

# Clear log file
> "$LOG_FILE"

# Display the start banner
print_start_banner

# Install and Configure Nginx
log_message "Configuring Nginx 1.24..."
dnf module disable nginx -y &>> "$LOG_FILE"
dnf module enable nginx:1.24 -y &>> "$LOG_FILE"
dnf install nginx -y &>> "$LOG_FILE"
dnf install bash-completion -y &>> "$LOG_FILE"
check_status "Nginx installation"

# Start Nginx service
log_message "Starting Nginx service..."
systemctl enable nginx &>> "$LOG_FILE"
systemctl start nginx &>> "$LOG_FILE"
check_status "Nginx service startup"

# Update Nginx configuration
log_message "Updating Nginx configuration..."
cp nginx.conf /etc/nginx/nginx.conf &>> "$LOG_FILE"
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
cd /usr/share/nginx/html
unzip -o /tmp/frontend.zip &>> "$LOG_FILE"
check_status "Frontend extraction"

# Restart Nginx
log_message "Restarting Nginx service..."
systemctl restart nginx &>> "$LOG_FILE"
check_status "Nginx restart"

# Cleanup
rm -f /tmp/frontend.zip

# Display the end banner
print_end_banner