
# Packages -----------------------------------------------------------------
require(EpiNow, quietly = TRUE)
require(NCoVUtils, quietly = TRUE)
require(future, quietly = TRUE)
require(dplyr, quietly = TRUE)
require(tidyr, quietly = TRUE)
require(magrittr, quietly = TRUE)
require(data.table)


# Get cases ---------------------------------------------------------------

NCoVUtils::reset_cache()

cases <- get_india_regional_cases(data = "cases") %>%
  dplyr::rename(region = name, region_code = state)


region_codes <- cases %>%
  dplyr::select(region, region_code) %>%
  unique()

saveRDS(region_codes, "india/data/region_codes.rds")

cases <- cases %>%
  dplyr::rename(local = cases) %>% 
  dplyr::mutate(imported = 0) %>%
  tidyr::gather(key = "import_status", value = "confirm", local, imported) %>% 
  tidyr::drop_na(region)

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

future::plan("multiprocess", workers = round(future::availableCores() / 2))


# Fit the reporting delay -------------------------------------------------

delay_defs <- EpiNow::get_dist_def(delays, 
                                   bootstraps = 100, samples = 1000)


# Run pipeline ----------------------------------------------------

EpiNow::regional_rt_pipeline(
  cases = cases,
  delay_defs = delay_defs,
  target_folder = "india/regional",
  horizon = 14,
  approx_delay = TRUE,
  report_forecast = TRUE,
  forecast_model = function(...) {EpiSoon::forecastHybrid_model(
    model_params = list(models = "aeftz", weights = "equal",
                        t.args = list(use_parallel = FALSE)),
    forecast_params = list(PI.combination = "mean"), ...)}
)


# Summarise results -------------------------------------------------------

EpiNow::regional_summary(results_dir = "india/regional",
                         summary_dir = "india/regional-summary",
                         target_date = "latest",
                         region_scale = "Region")
