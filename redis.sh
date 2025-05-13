source ./common.sh
LOG_FILE="/tmp/roboshop.log"
component="redis"

# Clear log file
> "$LOG_FILE"

# Install and Configure Redis
log_message "Installing Redis..." | tee -a "$LOG_FILE"
dnf module disable redis -y
dnf module enable redis:7 -y
dnf install redis bash-completion -y
check_status "Redis installation"


log_message "Updating Redis configuration..." | tee -a "$LOG_FILE"
sed -i 's/^bind 127\.0\.0\.1/bind 0.0.0.0/' /etc/redis/redis.conf &>> "$LOG_FILE"
sed -i 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>> "$LOG_FILE"
check_status "Redis configuration update"


log_message "Starting Redis service..." | tee -a "$LOG_FILE"
systemctl enable redis &>> "$LOG_FILE"
systemctl restart redis &>> "$LOG_FILE"
check_status "Redis service startup"