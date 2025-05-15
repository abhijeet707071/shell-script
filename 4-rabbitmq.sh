source ./common.sh
LOG_FILE="/tmp/roboshop.log"
component="rabbitmq"
rabbitmq_user="roboshop"
rabbitmq_user_pass="$1"
if [ -z "$rabbitmq_user_pass" ]; then
  echo -e "\n\e[1;31mPlease provide the RabbitMQ user password as an 1st argument.\e[0m"
  exit 1
fi
# Clear log file
> "$LOG_FILE"

# Display the start banner
print_start_banner
# Set hostname
hostname

log_message "Copy the RabbitMQ repo file ..." | tee -a "$LOG_FILE"
cp repo-files/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> "$LOG_FILE"
check_status "Repo Configuration"

log_message "Installing RabbitMQ..." | tee -a "$LOG_FILE"
dnf install rabbitmq-server -y &>> "$LOG_FILE"
check_status "RabbitMQ installation"

log_message "Start the RabbitMQ service..." | tee -a "$LOG_FILE"
systemctl enable rabbitmq-server &>> "$LOG_FILE"
systemctl restart rabbitmq-server &>> "$LOG_FILE"
check_status "RabbitMQ service start"

log_message "Create the RabbitMQ user..." | tee -a "$LOG_FILE"
user_check=$(rabbitmqctl list_users | grep -w "${rabbitmq_user}") &>> "$LOG_FILE"
if [ -z "$user_check" ]; then
  rabbitmqctl add_user ${rabbitmq_user} ${rabbitmq_user_pass} &>> "$LOG_FILE"
else
  echo -e "\n\e[1;32mUser ${rabbitmq_user} already exists.\e[0m"
fi
check_status "RabbitMQ user creation"

log_message "Set permission for ${rabbitmq_user} user..." | tee -a "$LOG_FILE"
rabbitmqctl set_permissions -p / ${rabbitmq_user} ".*" ".*" ".*" &>> "$LOG_FILE"
check_status "RabbitMQ user permission set"

# Display the end banner
print_end_banner



