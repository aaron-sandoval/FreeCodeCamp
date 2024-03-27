#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
PSQL2="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# TYPES=$($PSQL "SELECT DISTINCT type from properties;")
# echo $TYPES
# echo $TYPES | while read TYPE
# do
#   echo -e "$TYPE"
# done
EXTRACT_TYPES() {
  A=$($PSQL "UPDATE properties SET type_id=1 WHERE type='metal';")
  A=$($PSQL "UPDATE properties SET type_id=2 WHERE type='metalloid';")
  A=$($PSQL "UPDATE properties SET type_id=3 WHERE type='nonmetal';")
  A=$($PSQL "ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL;")
  A=$($PSQL "ALTER TABLE properties ADD FOREIGN KEY(type_id) REFERENCES types(type_id);")
}

CAPITALIZE_SYMBOLS(){
  # Get space-delimited string of symbols
  SYMBOLS=$($PSQL "SELECT symbol FROM elements;")
  # https://stackoverflow.com/questions/1538676/uppercasing-first-letter-of-words-using-sed
  # Calling `sed` on each individual symbol b/c I didn't want to look up how to do something like Python's `zip` in bash
  # Split symbols string into an array
  SYMBOLS=$(echo $SYMBOLS \ tr " ")  
  for SYMBOL in $SYMBOLS
  do
    # Capitalize symbol
    CAPPED=$(echo $SYMBOL | sed -e "s/\b\(.\)/\u\1/g")
    # Write capitalized symbol into db
    UPDATE=$($PSQL "UPDATE elements SET symbol='$CAPPED' where symbol='$SYMBOL';")
  done
}

EXTRACT_TYPES
# CAPITALIZE_SYMBOLS