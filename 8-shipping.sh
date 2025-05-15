# Main Script to install the shipping component
source ./common.sh

# Set the variables
LOG_FILE="/tmp/roboshop.log"
component="shipping"
schema_type="mysql"
mysql_root_password="$1"
if [ -z "${mysql_root_password}" ]; then
  echo -e "\n\e[1;31mPlease provide the MySQL root password as an 1st argument.\e[0m"
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
shipping

# Display the end banner
print_end_banner