
# Packages ----------------------------------------------------------------

require(data.table, quietly = TRUE)
require(EpiNow, quietly = TRUE)
require(lubridate, quietly = TRUE)

# Get linelist ------------------------------------------------------------


linelist <- 
  data.table::fread("https://raw.githubusercontent.com/epiforecasts/NCoVUtils/master/data-raw/linelist.csv")


delays <- linelist[!is.na(date_onset_symptoms)][, 
                   .(report_delay = as.numeric(lubridate::dmy(date_confirmation) - 
                                       as.Date(lubridate::dmy(date_onset_symptoms))))]

delays <- delays$report_delay

# Set up cores -----------------------------------------------------
if (!interactive()){
  options(future.fork.enable = TRUE)
}

future::plan("multiprocess", workers = round(future::availableCores()))


# Fit the reporting delay -------------------------------------------------

delay_defs <- EpiNow::get_dist_def(delays, 
                                   bootstraps = 100, samples = 1000)

saveRDS(delay_defs, "delays.rds")