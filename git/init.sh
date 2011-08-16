#!/bin/bash
#configures and send folder to github
FOLDER=$1

echo FOLDER BEFORE $FOLDER
FOLDER=${FOLDER%/*}
echo FOLDER AFTER  $FOLDER


git config --global user.name "sauloal"
git config --global user.email "sauloal@gmail.com"
mkdir $FOLDER 2>/dev/null
cd $FOLDER/
git init
touch README
git add .
git commit -m "first commit $FOLDER"
git remote add origin git@github.com:sauloal/$FOLDER.git
git push origin master

cd ..

