# Import banner functions
source $(dirname "$0")/banner_functions.sh

# Function to log messages
log_message() {
    echo -e "\n\e[1;33m$1\e[0m" | tee -a "$LOG_FILE"
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

hostname(){
  # Set the hostname
  log_message "Set Hostname..." | tee -a "$LOG_FILE"
  hostnamectl set-hostname ${component} &>> "$LOG_FILE"
  check_status "Set Hostname"
}

prereq_packages(){
  # Install Prerequisite packages
  log_message "Installing Prerequisite Packages..." | tee -a "$LOG_FILE"
  dnf install git curl unzip bash-completion -y &>> "$LOG_FILE"
  check_status "Prerequisite Packages Installation"
}

application-setup(){
    # Copy the application service file.
    log_message "Creating application service file..." | tee -a "$LOG_FILE"
    cp service-files/${component}.service /etc/systemd/system/${component}.service &>> "$LOG_FILE"
    check_status "Service file creation"

    # Create application user
    log_message "Creating application user..." | tee -a "$LOG_FILE"
    if id roboshop &>/dev/null; then
        echo -e "\e[32mUser 'roboshop' already exists.\e[0m"
    else
        useradd -m roboshop &>> "$LOG_FILE"
        check_status "User creation"
    fi

    # Remove old Application directory
    log_message "Removing Old Application Dir..." | tee -a "$LOG_FILE"
    if [ -d /app ]; then
      rm -rf /app &>> "$LOG_FILE"
      check_status "Remove Old App Dir"
    else
      echo -e "\e[32mDirectory '/app' does not exist.\e[0m"
    fi

    # Create Application directory
    log_message "Creating application dir..." | tee -a "$LOG_FILE"
    mkdir /app &>> "$LOG_FILE"
    check_status "App directory creation"

    # Download and extract Application content
    log_message "Downloading application content..." | tee -a "$LOG_FILE"
    curl -L -s -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}-v3.zip &>> "$LOG_FILE"
    check_status "App Content Download"

    # Extract Application content
    log_message "Extract App content..." | tee -a "$LOG_FILE"
    unzip -o /tmp/${component}.zip -d /app &>> "$LOG_FILE"
    check_status "App Content Extraction"
}

systemd_setup(){
    # Start the application service.
    log_message "Start the Application service ..." | tee -a "$LOG_FILE"
    systemctl daemon-reload &>> "$LOG_FILE"
    systemctl enable ${component} &>> "$LOG_FILE"
    systemctl restart ${component} &>> "$LOG_FILE"
    check_status "App Service start"
}

schema_load(){
  # Load the schema
  if [ ${schema_type} == "mongodb" ]; then
  log_message "Load the schema..." | tee -a "$LOG_FILE"
  cp repo-files/mongo.repo /etc/yum.repos.d/mongo.repo &>> "$LOG_FILE"
  dnf install mongodb-mongosh -y &>> "$LOG_FILE"
  mongosh --host mongodb.learntechnology.space </app/db/master-data.js &>> "$LOG_FILE"
  check_status "Schema Load"
  fi

  if [ ${schema_type} == "mysql" ]; then
  log_message "Load the schema..." | tee -a "$LOG_FILE"
  dnf install mysql -y &>> "$LOG_FILE"
  mysql -h mysql.learntechnology.space -uroot -p"${mysql_root_password}" < /app/db/schema.sql &>> "$LOG_FILE"
  mysql -h mysql.learntechnology.space -uroot -p"${mysql_root_password}" < /app/db/app-user.sql &>> "$LOG_FILE"
  mysql -h mysql.learntechnology.space -uroot -p"${mysql_root_password}" < /app/db/master-data.sql &>> "$LOG_FILE"
  check_status "Schema Load"
  fi
}

nodejs(){

  # Install NodeJS.
  log_message "Installing NodeJS 20..." | tee -a "$LOG_FILE"
  dnf module disable nodejs -y &>> "$LOG_FILE"
  dnf module enable nodejs:20 -y &>> "$LOG_FILE"
  dnf install nodejs -y &>> "$LOG_FILE"
  check_status "NodeJS installation"

  # Call Application setup function to configure the application.
  application-setup

  # Install application dependencies.
  log_message "Install application dependency..." | tee -a "$LOG_FILE"
  npm install -C /app &>> "$LOG_FILE"
  check_status "App Dependency Installation"

  # Load the schema.
  schema_load

  # Call systemd setup function to start the application.
  systemd_setup

}

shipping(){

  log_message "Install Maven..." | tee -a "$LOG_FILE"
  dnf install maven -y &>> "$LOG_FILE"
  check_status "Maven installation"

  # Call Application setup function to configure the application.
  application-setup

  log_message "Build the Application..." | tee -a "$LOG_FILE"
  mvn clean package -f /app/pom.xml &>> "$LOG_FILE"
  mv /app/target/${component}-1.0.jar /app/${component}.jar &>> "$LOG_FILE"
  check_status "Build Application"

  # Load the schema.
  schema_load

  # Call systemd setup function to start the application.
  systemd_setup

}
