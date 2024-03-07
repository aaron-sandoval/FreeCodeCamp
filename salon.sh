#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
SERVICES=$($PSQL "SELECT * FROM services;")

MAIN_MENU() {
  # Print services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
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
  SERVICE_ID=$1
  echo "You picked a $SERVICE_ID"
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
    RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  else
    CUSTOMER_NAME=$($PSQL "SELECT name from customers where phone='$CUSTOMER_PHONE';")
    # Strip whitespace from db query result
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -E 's/ *$|^ *//g')
  fi
  # Get customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone='$CUSTOMER_PHONE';")
  # Strip whitespace from db query result
  CUSTOMER_ID=$(echo $CUSTOMER_ID | sed -E 's/ *$|^ *//g')
  # echo $CUSTOMER_IDS | while read CUSTOMER_ID
  # echo $CUSTOMER_ID
  # Prompt time
  echo "What time for your appointment?"
  read SERVICE_TIME
  # Create new appointment
  # echo "'$CUSTOMER_ID', '$SERVICE_TIME', '$SERVICE_ID'"
  RESULT=$($PSQL "INSERT INTO appointments(customer_id, time, service_id) VALUES('$CUSTOMER_ID', '$SERVICE_TIME', '$SERVICE_ID');")
  # Print message
  SERVICE=$($PSQL "SELECT name from services where service_id='$SERVICE_ID';")
  # Strip whitespace from db query result
  SERVICE=$(echo $SERVICE | sed -E 's/ *$|^ *//g')
  echo "I have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
