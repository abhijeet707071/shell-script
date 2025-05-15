source ./common.sh

# Set the variables
LOG_FILE="/tmp/roboshop.log"
component="payment"
rabbitmq_user_name="roboshop"
rabbitmq_user_pass="$1"
if [ -z "$rabbitmq_user_pass" ]; then
  echo -e "\n\e[1;31mPlease provide the RabbitMQ user password as an 1st argument.\e[0m"
  exit 1
fi

# Clear old log file
cat /dev/null > "$LOG_FILE"

# Display the start banner
print_start_banner

# Set hostname
hostname

# Install Prerequisite packages
prereq_packages

# Call the function to set the component
payment

# Display the end banner
print_end_banner