#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

#ADDING Fluorine and Neon
# $PSQL "INSERT INTO elements(atomic_number, symbol, name) VALUES(9, 'F', 'Fluorine')"
# $PSQL "INSERT INTO properties(atomic_number, atomic_mass, melting_point_celcius, boiling_point_celcius, type_id) VALUES(9, 18.998, -220, -188.1, 1)"
# $PSQL "INSERT INTO elements(atomic_number, symbol, name) VALUES(10, 'Ne', 'Neon')"
# $PSQL "INSERT INTO properties(atomic_number, atomic_mass, melting_point_celcius, boiling_point_celcius, type_id) VALUES(10, 20.18, -248.6, -246.1, 1)"

### SCRIPT TO UPDATE THE NEW type_id ON PROPERTIES TABLE
ADD_TYPE_ID_RESULT=$($PSQL "SELECT * FROM properties WHERE type_id IS NULL");

if [[ ! -z "$ADD_TYPE_ID_RESULT" ]] #checks if there are any nulls
then
  echo "$ADD_TYPE_ID_RESULT" | while IFS="|" read ATOMIC_NUMBER TYPE ATOMIC_MASS MELTING_P BOILING_P TYPE_ID
  do
    if [[ -z "$TYPE_ID" ]]
    then
      case $TYPE in
      'nonmetal') NEW_ID=1 ;;
      'metal') NEW_ID=2 ;;
      'metalloid') NEW_ID=3 ;;
      esac

      SET_TYPE_ID_RESULT=$($PSQL "UPDATE properties SET type_id=$NEW_ID WHERE atomic_number=$ATOMIC_NUMBER")

      echo "$SET_TYPE_ID_RESULT"
    fi
  done
fi
### END SCRIPT

##SCRIPT TO UPDATE CAPITALS ON SYMBOLS
#if this script is needed, change CAPITALS to anything else
CAPITALS="finished"
if [[ "$CAPITALS" != "finished" ]]
then
  #get list of atomic_number and symbols
  ELEMENT_SYMBOL_UPDATE_LIST=$($PSQL "SELECT atomic_number, symbol FROM elements")

  #do loop for each, taking symbol and inserting sed'd symbol on atomic_number
  echo "$ELEMENT_SYMBOL_UPDATE_LIST" | while IFS="|" read ATOMIC_NUMBER SYMBOL
  do
    CAP_SYMBOL="${SYMBOL^}"
    UPDATE_CAP_RESULT=$($PSQL "UPDATE elements SET symbol='$CAP_SYMBOL' WHERE atomic_number=$ATOMIC_NUMBER")
    if [[ "$UPDATE_CAP_RESULT" == "UPDATE 1" ]]
    then
      echo "$SYMBOL" should now read "$CAP_SYMBOL" in the elements table.
    else
      echo Error updating "$SYMBOL".
    fi
  done
fi

#remove trailing zeroes from atomic_mass values in properties table
REMOVE_TRAILING_ZEROES_RESULT=$($PSQL "UPDATE properties SET atomic_mass = TRIM(TRAILING '0' FROM atomic_mass::TEXT)::NUMERIC;")

echo "Trailing zeroes removed."
