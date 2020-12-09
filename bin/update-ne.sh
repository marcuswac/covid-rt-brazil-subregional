#!/bin/bash

##Update delays
#Rscript R/update-delays.R

STATES_DIR="states"
STATES="AL BA CE MA PB PE PI RN SE"
#STATES="PB"

for state in $STATES
do
  echo "Updating $state"
  STATE_DIR=$STATES_DIR/$state
  
  ##Update data
  mv $STATE_DIR/data/cases/latest.csv $STATE_DIR/data/cases/previous.csv
  Rscript R/update-data-state.R $state $STATES_DIR latest

  ##Update Rt estimates
  rm -rf $STATE_DIR/data/rt/previous 
  mv $STATE_DIR/data/rt/latest $STATE_DIR/data/rt/previous
  Rscript R/update-rt-state.R $state $STATES_DIR latest

  ##Update report
  mkdir -p $STATE_DIR/docs
  cp -r docs/index.Rmd docs/header.html docs/footer.html $STATE_DIR/docs/
  cp -r data/shapefile $STATE_DIR/data/
  touch $STATE_DIR/.here
  Rscript -e "rmarkdown::render('$STATE_DIR/docs/index.Rmd')"
done
