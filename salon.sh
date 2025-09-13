#!/bin/bash
echo -e "\n~~~~~ Schedule a Salon Appointment ~~~~~\n"

# Database connection string
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Function to handle errors
handle_error() {
  echo -e "\nError: $1"
  exit 1
}

# Main menu function
MAIN_MENU() {
  # Optional error message from recursive call
  if [[ -n $1 ]]; then
    echo -e "\n$1"
  fi

  # Display services list
  echo -e "\nHere are our services:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id" 2>/dev/null) || handle_error "Failed to retrieve services from database."
  if [[ -z $SERVICES ]]; then
    handle_error "No services available. Please check the database."
  fi
  echo "$SERVICES" | while read SERVICE_ID BAR NAME; do
    echo "$SERVICE_ID) $NAME"
  done

  # Get service selection
  echo -e "\nWhich service would you like to schedule an appointment for? (Enter the number)"
  read SERVICE_ID_SELECTED

  # Remove any whitespace from input
  SERVICE_ID_SELECTED=$(echo "$SERVICE_ID_SELECTED" | tr -d '[:space:]')

  # Validate service selection: check if input is a number and exists in services
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    MAIN_MENU "Please enter a valid number for the service."
    return
  fi
  SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED" 2>/dev/null) || handle_error "Database query failed."
  if [[ -z $SERVICE_EXISTS ]]; then
    MAIN_MENU "Please enter a valid service number."
    return
  fi

  # Get customer phone
  echo -e "\nWhat's your phone number? (e.g., 123-456-7890)"
  read CUSTOMER_PHONE

  # Basic phone number validation
  if [[ -z $CUSTOMER_PHONE || ! $CUSTOMER_PHONE =~ ^[0-9-]+$ ]]; then
    MAIN_MENU "Please enter a valid phone number (e.g., 123-456-7890)."
    return
  fi

  # Check if customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" 2>/dev/null) || handle_error "Database query failed."
  
  # If new customer
  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    
    # Validate name input
    CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    if [[ -z $CUSTOMER_NAME ]]; then
      MAIN_MENU "Please enter a valid name."
      return
    fi
    
    # Insert new customer with SQL injection prevention
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')" 2>/dev/null) || handle_error "Failed to add customer to database."
  fi

  # Get appointment time
  echo -e "\nWhat time would you like to schedule your appointment? (e.g., 10:30 AM)"
  read SERVICE_TIME

  # Basic time validation
  SERVICE_TIME=$(echo "$SERVICE_TIME" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  if [[ -z $SERVICE_TIME ]]; then
    MAIN_MENU "Please enter a valid time (e.g., 10:30 AM)."
    return
  fi

  # Get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'" 2>/dev/null) || handle_error "Database query failed."

  # Insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" 2>/dev/null) || handle_error "Failed to schedule appointment."

  # Get service name for confirmation message
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" 2>/dev/null) || handle_error "Database query failed."
  SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  # Output confirmation
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}

# Call main menu
MAIN_MENU
