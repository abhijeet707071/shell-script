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

# Install and Maven
dnf install maven bash-completion -y &>> "$LOG_FILE"

# Create application user
if id roboshop &>/dev/null;then
  echo -e "\e[32mUser 'roboshop' already exists.\e[0m"
else
  useradd -m roboshop &>> "$LOG_FILE"
  check_status "User creation"
fi

# Remove old application directory
if [ -d /app ]; then
  rm -rf /app &>> "$LOG_FILE"
  check_status "Remove Old App Dir"
else
  echo -e "\e[32mDirectory '/app' does not exist.\e[0m"
fi

# Create application directory
mkdir /app &>> "$LOG_FILE"

# Download and extract shipping content
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> "$LOG_FILE"
unzip -o /tmp/shipping.zip -d /app &>> "$LOG_FILE"

# Install application dependency and create the artifact.
mvn clean package -f /app/pom.xml &>> "$LOG_FILE"
mv /app/target/shipping-1.0.jar /app/shipping.jar &>> "$LOG_FILE"

# Create application service file
cp shipping.service /etc/systemd/system/shipping.service &>> "$LOG_FILE"

# Update the systemd daemon
systemctl daemon-reload &>> "$LOG_FILE"
# Start the application
systemctl enable shipping &>> "$LOG_FILE"
systemctl restart shipping &>> "$LOG_FILE"

# Load the schema
dnf install mysql -y
mysql -h mysql.learntechnology.space -uroot -p"$1" < /app/db/schema.sql &>> "$LOG_FILE"
mysql -h mysql.learntechnology.space -uroot -p"$1" < /app/db/app-user.sql &>> "$LOG_FILE"
mysql -h mysql.learntechnology.space -uroot -p"$1" < /app/db/master-data.sql &>> "$LOG_FILE"

systemctl restart shipping &>> "$LOG_FILE"

# Display the end banner
print_end_banner