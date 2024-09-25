#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

### search for related atomic_number, initial, or name based on $1
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # Input is a number, compare with atomic_number
    GET_ELEM_RESULT=$($PSQL "SELECT elements.atomic_number, elements.name, elements.symbol, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = $1")
  else
    # Input is a string, compare with symbol or name
    GET_ELEM_RESULT=$($PSQL "SELECT elements.atomic_number, elements.name, elements.symbol, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol = '$1' OR name = '$1'")
  fi

  ### if not found
  if [[ -z "$GET_ELEM_RESULT" ]]
  then
    echo "I could not find that element in the database."

  ### else parse data for easy reading
  else
  echo "$GET_ELEM_RESULT" | while IFS="|" read ATOMIC_NUMBER ELEM_NAME ELEM_SYM ATOMIC_MASS MELT_POINT BOIL_POINT TYPE
  do
      echo "The element with atomic number $ATOMIC_NUMBER is $ELEM_NAME ($ELEM_SYM). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $ELEM_NAME has a melting point of $MELT_POINT celsius and a boiling point of $BOIL_POINT celsius."
  done
  fi
fi