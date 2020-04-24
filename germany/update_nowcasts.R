
# Packages -----------------------------------------------------------------
require(EpiNow)
require(NCoVUtils)
require(furrr)
require(future)
require(dplyr)
require(tidyr)
require(magrittr)
require(future.apply)
require(fable)
require(fabletools)
require(feasts)
require(urca)


# Get cases ---------------------------------------------------------------

NCoVUtils::reset_cache()

cases <- get_germany_regional_cases()


region_codes <- cases %>%
  dplyr::select(region, region_code) %>%
  unique()

saveRDS(region_codes, "germany/data/region_codes.rds")

cases <- cases %>%
  dplyr::rename(local = cases) %>%
  dplyr::mutate(imported = 0) %>%
  tidyr::gather(key = "import_status", value = "cases", local, imported) %>% 
  tidyr::drop_na(region)

# Get linelist ------------------------------------------------------------

linelist <- NCoVUtils::get_international_linelist()

# Set up cores -----------------------------------------------------

future::plan("multiprocess", workers = future::availableCores())

data.table::setDTthreads(threads = 1)

# Run pipeline ----------------------------------------------------

EpiNow::regional_rt_pipeline(
  cases = cases,
  linelist = linelist,
  target_folder = "germany/regional",
  regional_delay = FALSE,
  horizon = 14,
  report_forecast = TRUE,
  forecast_model = function(...) {
    EpiSoon::fable_model(model = fabletools::combination_model(fable::RW(y ~ drift()), fable::ETS(y), 
                                                               fable::NAIVE(y),
                                                               cmbn_args = list(weights = "inv_var")), ...)
  },
  samples = 10
)


# Summarise results -------------------------------------------------------

EpiNow::regional_summary(results_dir = "germany/regional",
                         summary_dir = "germany/regional-summary",
                         target_date = "latest",
                         region_scale = "Region")
