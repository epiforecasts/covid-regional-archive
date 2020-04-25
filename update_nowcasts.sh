#!/bin/bash

## Run regions in parallel
Rscript germany/update_nowcasts.R & 
Rscript italy/update_nowcasts.R &
Rscript united-kingdom/update_nowcasts.R &
wait

## Run USA last
Rscript united-states/update_nowcasts.R
