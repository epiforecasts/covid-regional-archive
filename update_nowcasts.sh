#!/bin/bash

## Make sure everything is up to date
git pull

## Run germany, italy, UK in parallel
Rscript germany/update_nowcasts.R & 
Rscript italy/update_nowcasts.R &
Rscript united-kingdom/update_nowcasts.R &
wait
## Run the USA 
Rscript united-states/update_nowcasts.R

## Update master with then new results
git add --all
git commit -m "Updated nowcasts"
git push
