#!/bin/bash

## Run germany, italy, UK in parallel
Rscript germany/update_nowcasts.R & 
Rscript italy/update_nowcasts.R &
Rscript united-kingdom/update_nowcasts.R &
wait
## Run the USA 
Rscript united-states/update_nowcasts.R
