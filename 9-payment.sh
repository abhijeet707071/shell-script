source ./common.sh
LOG_FILE="/tmp/roboshop.log"
component="paymnent"

# Clear log file
> "$LOG_FILE"

# Display the start banner
print_start_banner

dnf install python3 gcc python3-devel -y

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
  check_status "Remove Old App Dir"
else
  echo -e "\e[32mDirectory '/app' does not exist.\e[0m"
fi


log_message "Creating application dir..." | tee -a "$LOG_FILE"
mkdir /app &>> "$LOG_FILE"
check_status "App directory creation"


curl -L -s -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>> "$LOG_FILE"
unzip -o /tmp/payment.zip -d /app &>> "$LOG_FILE"


pip3 install -r /app/requirements.txt

cp service-files/payment.service /etc/systemd/system/payment.service

sed -i 's/rabbitmq_user/${rabbitmq_user}/' /etc/systemd/system/payment.service
sed -i 's/rabbitmq_user_pass/${rabbitmq_user_pass}/' /etc/systemd/system/payment.service

log_message "Start the Application ..." | tee -a "$LOG_FILE"
systemctl daemon-reload &>> "$LOG_FILE"
systemctl enable catalogue &>> "$LOG_FILE"
systemctl restart catalogue &>> "$LOG_FILE"
check_status "Service start"