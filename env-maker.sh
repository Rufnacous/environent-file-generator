#Environment variable file creator by Rufus D

#Default values
FILE=".env"
RANDOMLEN=32
DEFINITIONFILE=$1
if [[ "$1" = "" ]]; then
  DEFINITIONFILE=".envdefinition"
fi
echo "Reading definition file: $DEFINITIONFILE"
echo ""

while read LINE;
do
  #Use "@SPECIFY fname" lines to switch to a different environment file
  if [[ "$LINE" == *"@SPECIFY"* ]]; then
    IFS=" "
    read -a arr0 <<< "$LINE"
    ENVFILE="${arr0[1]}"
    echo "Writing into environment file: $ENVFILE"
  fi

  #Use "VARIABLENAME::inputtype" lines to define a variable that needs inputting
  if [[ "$LINE" == *"::"* ]]; then
    IFS="::"
    read -a arr1 <<< "$LINE"
    MODE="${arr1[2]}"

    #inputtype random will generate a random string of RANDOMLEN characters
    if [[ "$MODE" == "random" ]]; then
      read -a arr1 <<< "$LINE"
      NAME="${arr1[0]}"
      (echo -n "$NAME=" ; head /dev/urandom | tr -dc A-Za-z0-9 | head -c $RANDOMLEN ; echo '') >> $ENVFILE
    fi

    #inputtype input will take user input, with the -s flag to hide the input
    if [[ "$MODE" == "input" ]]; then
      NAME="${arr1[0]}"
      echo "Please enter value for $NAME or enter r/R for random:"
      read -s VALUE </dev/tty
      if [[ "$VALUE" = "r/R" ]]; then
        (echo -n "$NAME=" ; head /dev/urandom | tr -dc A-Za-z0-9 | head -c $RANDOMLEN ; echo '') >> $ENVFILE
      else
        echo "$NAME=$VALUE" >> $ENVFILE
      fi
    fi

  fi
done <$DEFINITIONFILE
