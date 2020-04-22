
# Packages -----------------------------------------------------------------
require(EpiNow)
require(NCoVUtils)
require(furrr)
require(future)
require(dplyr)
require(tidyr)
require(magrittr)



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
  tidyr::gather(key = "import_status", value = "cases", local, imported)

# Get linelist ------------------------------------------------------------

linelist <- NCoVUtils::get_international_linelist()

# Set up cores -----------------------------------------------------

future::plan("multiprocess", workers = future::availableCores())

data.table::setDTthreads(threads = 1)

# Run pipeline ----------------------------------------------------

EpiNow::regional_rt_pipeline(
  cases = cases,
  linelist = linelist,
  regional_delay = FALSE,
  target_folder = "united-states/regional"
)


# Summarise results -------------------------------------------------------

EpiNow::regional_summary(results_dir = "united-states/regional",
                         summary_dir = "united-states/regional-summary",
                         target_date = "latest",
                         region_scale = "State")

# Save summary csv --------------------------------------------------------

source(here::here("../../utils/save_summary_csv.R"))


save_summary_csv(results_dir = "united-states/regional",
                 summary_dir = "united-states/regional-summary",
                 type = "region")
