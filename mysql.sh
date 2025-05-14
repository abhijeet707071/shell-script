source ./common.sh
LOG_FILE="/tmp/roboshop.log"
component="mysql"
# Clear log file
> "$LOG_FILE"

# Display the start banner
print_start_banner

if [ -z "$1" ]; then
  echo -e "\n\e[1;31mPlease provide the MySQL root password as an 1st argument.\e[0m"
  exit 1
fi

# Set hostname
hostname

# Install MySQL
log_message "Installing Mysql server..." | tee -a "$LOG_FILE"
dnf install mysql-server bash-completion -y &>> "$LOG_FILE"
check_status "Mysql installation"


log_message "Start mysql..." | tee -a "$LOG_FILE"
systemctl enable mysqld &>> "$LOG_FILE"
systemctl restart mysqld &>> "$LOG_FILE"
check_status "Mysql service start"


log_message "Configure the root password..." | tee -a "$LOG_FILE"
mysql_secure_installation --set-root-pass "$1" &>> "$LOG_FILE"
check_status "Mysql root password set"

# Display the end banner
print_end_banner
