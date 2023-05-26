#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games;")
cat games.csv | while IFS="," read YEAR ROUND WIN OPP WIN_G OPP_G
do
  if [[ $YEAR == year ]]
  then
    continue
  fi
  # Add winner and opp to teams
  winnerOut=$($PSQL "SELECT name FROM teams WHERE name='$WIN' OR name='$OPP';")
  # echo Won $winnerOut
  if [[ -z $winnerOut ]]
  then
    insertOut=$($PSQL "INSERT INTO teams(name) VALUES('$WIN'),('$OPP');")
    # echo $insertOut
  elif [[ $winnerOut == $WIN ]]
  then
    insertOut=$($PSQL "INSERT INTO teams(name) VALUES('$OPP');")
    # echo $insertOut
  elif [[ $winnerOut == $OPP ]]
  then
    insertOut=$($PSQL "INSERT INTO teams(name) VALUES('$WIN');")
    # echo $insertOut
  fi
  # Get team_ids
  winID=$($PSQL "SELECT team_id FROM teams WHERE name='$WIN';")
  oppID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP';")
  echo WinID $winID oppID $oppID
  # Add all fields to games
  insertOut=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', '$winID', '$oppID', '$WIN_G', '$OPP_G');")
  echo insertOut
done