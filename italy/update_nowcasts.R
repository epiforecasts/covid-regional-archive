
# Packages -----------------------------------------------------------------
require(EpiNow, quietly = TRUE)
require(NCoVUtils, quietly = TRUE)
require(furrr, quietly = TRUE)
require(future, quietly = TRUE)
require(readr, quietly = TRUE)
require(dplyr, quietly = TRUE)
require(tidyr, quietly = TRUE)
require(purrr, quietly = TRUE)
require(magrittr, quietly = TRUE)
require(future.apply, quietly = TRUE)
require(fable, quietly = TRUE)
require(fabletools, quietly = TRUE)
require(feasts, quietly = TRUE)
require(urca, quietly = TRUE)



# Get cases ---------------------------------------------------------------

NCoVUtils::reset_cache()

cases <- NCoVUtils::get_italy_regional_cases()


region_codes <- cases %>%
  dplyr::select(region, region_code) %>%
  unique() %>%
  dplyr::mutate(region_code = as.numeric(region_code))

saveRDS(region_codes, "italy/data/region_codes.rds")

cases <- cases %>%
  dplyr::rename(local = cases) %>%
  dplyr::select(-region_code) %>%
  dplyr::mutate(imported = 0) %>%
  tidyr::gather(key = "import_status", value = "cases", local, imported)

# Get linelist ------------------------------------------------------------

linelist <- NCoVUtils::get_international_linelist()

# Set up cores -----------------------------------------------------
if (!interactive()){
  options(future.fork.enable = TRUE)
}

future::plan("multiprocess", workers = future::availableCores())

data.table::setDTthreads(threads = 1)

# Run pipeline ----------------------------------------------------

EpiNow::regional_rt_pipeline(
  cases = cases,
  linelist = linelist,
  regional_delay = FALSE,
  target_folder = "italy/regional",
  horizon = 14,
  report_forecast = TRUE,
  forecast_model = function(...) {
    EpiSoon::fable_model(model = fabletools::combination_model(fable::RW(y ~ drift()), fable::ETS(y), 
                                                               fable::NAIVE(y),
                                                               cmbn_args = list(weights = "inv_var")), ...)
  }
)


# Summarise results -------------------------------------------------------


EpiNow::regional_summary(results_dir = "italy/regional",
                         summary_dir = "italy/regional-summary",
                         target_date = "latest",
                         region_scale = "Region")

