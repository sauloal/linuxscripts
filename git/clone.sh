#!/bin/bash
# download project from girhub
PROJECT=$1

echo FOLDER BEFORE $PROJECT
PROJECT=${PROJECT%/*}
echo FOLDER AFTER  $PROJECT

git clone  git@github.com:sauloal/$PROJECT.git
