#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -c "


SERVICES=$($PSQL "SELECT * FROM services;")

MAIN_MENU() {
  # Print services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    if [[ ! $SERVICE_ID =~ ^[0-9]+$ ]]
    then
      continue
    fi
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done
  # Get user input
  echo -e "\nPick a service:"
  read SERVICE_ID_SELECTED
  # If selection not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # Send back to main menu
    MAIN_MENU
    return
  fi
  # If selection not a valid number
  SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id='$SERVICE_ID_SELECTED';")
  if [[ ! $SERVICE_AVAILABLE =~ $SERVICE_ID_SELECTED ]]
  then
    # Send back to main menu
    MAIN_MENU
    return
  fi
  BOOKING $SERVICE_ID_SELECTED
}

BOOKING() {
  echo "Enter your phone: "
  read CUSTOMER_PHONE
  # If phone not already in db
  EXISTING_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE';")
  if [[ ! $EXISTING_PHONE =~ $CUSTOMER_PHONE ]]
  then
    # Prompt name
    echo "Enter your name: "
    read CUSTOMER_NAME
    # Add new customer to db
    $($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  fi
  # Get customer ID
  CUSTOMER_IDS=$($PSQL "SELECT customer_id from customers where phone='$CUSTOMER_PHONE';")
  # echo $CUSTOMER_IDS | while read 
  echo $CUSTOMER_IDS
  # Prompt time
  echo "What time for your appointment?"
  read SERVICE_TIME
  # Create new appointment
  $($PSQL "INSERT INTO appointments()")
  # Print message
}

MAIN_MENU
