#!bin/bash

##Update data
Rscript R/update-data.R

##Update delays
Rscript R/update-delays.R

##Update Rt estimates
Rscript R/update-rt.R

##Update report
Rscript -e "rmarkdown::render('docs/index.Rmd')"
