#!/bin/bash

## Make sure everything is up to date
git pull

## Run germany
Rscript germany/update_nowcasts.R
## Run the Italy
Rscript italy/update_nowcasts.R 
## Run UK
Rscript united-kingdom/update_nowcasts.R
## Run the USA 
Rscript united-states/update_nowcasts.R

## Update master with then new results
git add --all
git commit -m "Updated nowcasts"
git push
