# Catalogue Installation and Configuration Script
source ./common.sh

# Set the variables
LOG_FILE="/tmp/roboshop.log"
component="catalogue"
schema_type="mongodb"

# Clear old log file
cat /dev/null > "$LOG_FILE"

# Display the start banner
print_start_banner

# Set hostname
hostname

# Install Prerequisite packages
prereq_packages

# Call the function to set the component
nodejs

# Display the end banner
print_end_banner





