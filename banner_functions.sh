#!/bin/bash

# Function to display a stylish start banner
print_start_banner() {
  local script_name=$(basename "$0")
  local width=60
  local padding=$(( (width - ${#script_name} - 18) / 2 ))

  echo
  echo -e "\e[1;34m┏$("printf '━%.0s' {1..$width}")┓\e[0m"
  echo -e "\e[1;34m┃$("printf ' %.0s' {1..$width}")┃\e[0m"
  echo -e "\e[1;34m┃$("printf ' %.0s' {1..$padding}")\e[1;97m🚀 STARTING: $script_name 🚀\e[1;34m$("printf ' %.0s' {1..$padding}")┃\e[0m"
  echo -e "\e[1;34m┃$("printf ' %.0s' {1..$width}")┃\e[0m"
  echo -e "\e[1;34m┗$("printf '━%.0s' {1..$width}")┛\e[0m"
  echo
}

# Function to display a stylish end banner for success
print_end_banner() {
  local script_name=$(basename "$0")
  local width=60
  local padding=$(( (width - ${#script_name} - 18) / 2 ))

  echo
  echo -e "\e[1;32m┏$("printf '━%.0s' {1..$width}")┓\e[0m"
  echo -e "\e[1;32m┃$("printf ' %.0s' {1..$width}")┃\e[0m"
  echo -e "\e[1;32m┃$("printf ' %.0s' {1..$padding}")\e[1;97m✅ COMPLETED: $script_name ✅\e[1;32m$("printf ' %.0s' {1..$padding}")┃\e[0m"
  echo -e "\e[1;32m┃$("printf ' %.0s' {1..$width}")┃\e[0m"
  echo -e "\e[1;32m┗$("printf '━%.0s' {1..$width}")┛\e[0m"
  echo
}

# Function to display a stylish end banner for failure
print_error_banner() {
  local script_name=$(basename "$0")
  local width=60
  local padding=$(( (width - ${#script_name} - 16) / 2 ))

  echo
  echo -e "\e[1;31m┏$("printf '━%.0s' {1..$width}")┓\e[0m"
  echo -e "\e[1;31m┃$("printf ' %.0s' {1..$width}")┃\e[0m"
  echo -e "\e[1;31m┃$("printf ' %.0s' {1..$padding}")\e[1;97m❌ FAILED: $script_name ❌\e[1;31m$("printf ' %.0s' {1..$padding}")┃\e[0m"
  echo -e "\e[1;31m┃$("printf ' %.0s' {1..$width}")┃\e[0m"
  echo -e "\e[1;31m┗$("printf '━%.0s' {1..$width}")┛\e[0m"
  echo
}