#!/bin/bash

#query database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#prompt the user for a username
echo "Enter your username:"
read USERNAME

#pull user information
USER=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")


#welcome message to user
if [[ $USER ]]
then
  NUM_GAMES=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM users INNER JOIN games USING(user_id) WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $NUM_GAMES games, and your best game took $BEST_GAME guesses."
else
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

#randomly generate a number 1-1000
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

#guess the secret number between 1 and 1000:
echo "Guess the secret number between 1 and 1000:"
read GUESS
COUNT=1

#loop for guessing game
while [[ $GUESS != $SECRET_NUMBER ]]
do
  #if anything other than an integer is input as a guess
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  #if the previous input was higher than the secret number
  elif [[ $GUESS > $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  #if the previous input was lower than the secret number
  elif [[ $GUESS < $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi

  #prompt user for another guess
  read GUESS

  #increase guess counter by 1
  COUNT=$(( $COUNT + 1 ))
done

#when the secret number is guessed
#add game to database
INSERT_GAME=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER, $COUNT)")

echo "You guessed it in $COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
