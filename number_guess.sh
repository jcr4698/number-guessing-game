#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "Enter your username:"
read NAME

username=$($PSQL "SELECT name FROM users WHERE name='$NAME'")
games_played=0
best_game=-1
if [ -z $username ]; then
        res=$($PSQL "INSERT INTO users (name) VALUES ('$NAME')")
        echo -e "\nWelcome, $NAME! It looks like this is your first time here."
        username=$NAME
else
        games_played=$($PSQL "SELECT games_played FROM users WHERE name='$username'")
        best_game=$($PSQL "SELECT best_game FROM users WHERE name='$username'")
        echo -e "\nWelcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

curr_guess=-1
guess_count=(0)
rand_num=$((1 + $RANDOM % 1000))
#echo "$rand_num"
echo -e "\nGuess the secret number between 1 and 1000:"
while [[ $curr_guess != $rand_num ]]; do
        read curr_guess

        num_re='^[0-9]+$'
        if [[ $curr_guess =~ $num_re ]]; then

                if [[ $curr_guess > $rand_num ]]; then
                        echo "It's lower than that, guess again:"
                else
                        if [[ $curr_guess < $rand_num ]]; then
                                echo "It's higher than that, guess again:"
                        fi
                fi

        else
                echo "That is not an integer, guess again:"
        fi
        guess_count=$(($guess_count + 1))
done
echo -e "\nYou guessed it in $guess_count tries. The secret number was $rand_num. Nice job!"
if [[ $best_game == -1 ]] || [[ $guess_count < $best_game ]]; then
        res=$($PSQL "UPDATE users SET best_game=$guess_count WHERE name='$username';")
fi
games_played=$(($games_played + 1))
res=$($PSQL "UPDATE users SET games_played=$games_played WHERE name='$username';")
