
# Packages -----------------------------------------------------------------
require(EpiNow, quietly = TRUE)
require(NCoVUtils, quietly = TRUE)
require(future, quietly = TRUE)
require(dplyr, quietly = TRUE)
require(tidyr, quietly = TRUE)
require(magrittr, quietly = TRUE)
require(forecastHybrid, quietly = TRUE)



# Get cases ---------------------------------------------------------------

NCoVUtils::reset_cache()

cases <- get_us_regional_cases() %>%
  dplyr::rename(region = state)


region_codes <- cases %>%
  dplyr::select(region, region_code = fips) %>%
  unique()

saveRDS(region_codes, "united-states/data/region_codes.rds")

cases <- cases %>%
  dplyr::select(date, region, cases) %>%
  dplyr::rename(local = cases) %>%
  dplyr::mutate(imported = 0) %>%
  tidyr::gather(key = "import_status", value = "confirm", local, imported)

# Shared delay ------------------------------------------------------------

delay_defs <- readRDS("delays.rds")

# Set up cores -----------------------------------------------------
if (!interactive()){
  options(future.fork.enable = TRUE)
}

future::plan("multiprocess", workers = round(future::availableCores() / 3), gc = TRUE, earlySignal = TRUE)


# Run pipeline ----------------------------------------------------


EpiNow::regional_rt_pipeline(
  cases = cases,
  delay_defs = delay_defs,
  target_folder = "united-states/regional",
  horizon = 14,
  nowcast_lag = 10,
  approx_delay = TRUE,
  report_forecast = TRUE,
  forecast_model =  function(y, ...){EpiSoon::forecastHybrid_model(
    y = y[max(1, length(y) - 21):length(y)],
    model_params = list(models = "aefz", weights = "equal"),
    forecast_params = list(PI.combination = "mean"), ...)}
)


# Summarise results -------------------------------------------------------

EpiNow::regional_summary(results_dir = "united-states/regional",
                         summary_dir = "united-states/regional-summary",
                         target_date = "latest",
                         region_scale = "State")

