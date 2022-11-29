#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t -c"
NUMBER=$((RANDOM % 1000 + 1))
GUESS=101
NUM_GUESSES=0
echo Enter your username:
read USERNAME
USER=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")
if [[ -z $USER ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username,games_played,best_game) VALUES('$USERNAME',0,0)") 
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "$USER" | while read USER_NAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi
echo "Guess the secret number between 1 and 1000:"
while [[ $GUESS -ne $NUMBER ]]
do
  read GUESS
  ((NUM_GUESSES++))
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -gt $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done

BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
if [[ $BEST_GAME -eq 0 ]]
then
  UPDATE_USER=$($PSQL "UPDATE users SET best_game = $NUM_GUESSES WHERE username='$USERNAME'")
elif [[ $NUM_GUESSES -lt $BEST_GAME ]]
then
  UPDATE_USER=$($PSQL "UPDATE users SET best_game = $NUM_GUESSES WHERE username='$USERNAME'")
fi
UPDATE_USER=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")
echo "You guessed it in $NUM_GUESSES tries. The secret number was $NUMBER. Nice job!"