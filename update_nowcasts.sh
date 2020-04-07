#!/bin/bash

## Make sure everything is up to date
git pull

## Run germany, italy and UK in parallel as we have 48 cores available
Rscript germany/update_nowcasts.R &
Rscript italy/update_nowcasts.R &
Rscript united-kingdom/update_nowcasts.R &
wait
## Run the USa on its own as fully saturates available cores
Rscript germany/update_nowcasts.R

## Update master with then new results
git add --all
git commit -m "Updated nowcasts"
git push
