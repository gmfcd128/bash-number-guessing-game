#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME
USER_DATA=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
if [[ -z $USER_DATA ]]
then
  CREATE_NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  IFS='|' read -r USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< $USER_DATA
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo "Guess the secret number between 1 and 1000:"
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0
read USER_INPUT
NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
while ! [[ $USER_INPUT == $SECRET_NUMBER ]]
do 
  pat="^[0-9][0-9]*$"
  if [[ ! "$USER_INPUT" =~ $pat ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $USER_INPUT -ge $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $USER_INPUT -le $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
  read USER_INPUT
  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
UPDATE_GAME_STAT=$($PSQL "UPDATE users
SET games_played = games_played + 1,
    best_game = CASE WHEN best_game IS NULL THEN $NUMBER_OF_GUESSES
    WHEN $NUMBER_OF_GUESSES < best_game THEN $NUMBER_OF_GUESSES 
    ELSE best_game
    END
WHERE username = '$USERNAME'")
