#!/bin/bash

# Color codes
GREEN='\e[32m'
YELLOW='\e[33m'
RED='\e[31m'
RESET='\e[0m'

# Frontend Installation and Configuration Script
LOG_FILE="/tmp/roboshop.log"

# Set error handling
#set -e

# Function to log messages
log_message() {
    echo -e "\e[33m$1\e[0m" | tee -a "$LOG_FILE"
}

# Function to check status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "\e[32mSUCCESS: $1\e[0m" | tee -a "$LOG_FILE"
    else
        echo -e "\e[31mFAILED: $1\e[0m" | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Clear log file
> "$LOG_FILE"

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

log_message "Frontend installation completed successfully!"