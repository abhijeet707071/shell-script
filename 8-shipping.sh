source ./common.sh
LOG_FILE="/tmp/roboshop.log"
component="shipping"

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

log_message "Install Maven..." | tee -a "$LOG_FILE"
dnf install maven -y &>> "$LOG_FILE"
check_status "Maven installation"

log_message "Create application user..." | tee -a "$LOG_FILE"
if id roboshop &>/dev/null;then
  echo -e "\e[32mUser 'roboshop' already exists.\e[0m"
else
  useradd -m roboshop &>> "$LOG_FILE"
  check_status "User creation"
fi
check_status "User creation"

log_message "Remove old application dir..." | tee -a "$LOG_FILE"
if [ -d /app ]; then
  rm -rf /app &>> "$LOG_FILE"
  check_status "Remove Old App Dir"
else
  echo -e "\e[32mDirectory '/app' does not exist.\e[0m"
fi
check_status "Remove Old App Dir"

log_message "Creating application dir..." | tee -a "$LOG_FILE"
mkdir /app &>> "$LOG_FILE"
check_status "App directory creation"

log_message "Extracting application content..." | tee -a "$LOG_FILE"
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> "$LOG_FILE"
unzip -o /tmp/shipping.zip -d /app &>> "$LOG_FILE"
check_status "App Content Download"

log_message "Build the Application..." | tee -a "$LOG_FILE"
mvn clean package -f /app/pom.xml &>> "$LOG_FILE"
mv /app/target/shipping-1.0.jar /app/shipping.jar &>> "$LOG_FILE"
check_status "Build Application"

log_message "Creating ${component} service file..." | tee -a "$LOG_FILE"
cp shipping.service /etc/systemd/system/shipping.service &>> "$LOG_FILE"
check_status "Service file creation"

log_message "Load the schema..." | tee -a "$LOG_FILE"
dnf install mysql -y &>> "$LOG_FILE"
mysql -h mysql.learntechnology.space -uroot -p"$1" < /app/db/schema.sql &>> "$LOG_FILE"
mysql -h mysql.learntechnology.space -uroot -p"$1" < /app/db/app-user.sql &>> "$LOG_FILE"
mysql -h mysql.learntechnology.space -uroot -p"$1" < /app/db/master-data.sql &>> "$LOG_FILE"
check_status "Schema Load"

log_message "Start the Application..." | tee -a "$LOG_FILE"
systemctl daemon-reload &>> "$LOG_FILE"
systemctl enable shipping &>> "$LOG_FILE"
systemctl restart shipping &>> "$LOG_FILE"
check_status "Service start"

# Display the end banner
print_end_banner