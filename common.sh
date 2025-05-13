# Function to log messages
log_message() {
    echo -e "\e[33m$1\e[0m" | tee -a "$LOG_FILE"
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