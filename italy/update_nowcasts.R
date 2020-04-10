
# Packages -----------------------------------------------------------------
require(EpiNow)
require(NCoVUtils)
require(furrr)
require(future)
require(readr)
require(dplyr)
require(tidyr)
require(purrr)
require(magrittr)



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

future::plan("multiprocess", workers = future::availableCores())

# Run pipeline ----------------------------------------------------

EpiNow::regional_rt_pipeline(
  cases = cases,
  linelist = linelist,
  regional_delay = FALSE,
  target_folder = "italy/regional"
)


# Summarise results -------------------------------------------------------


EpiNow::regional_summary(results_dir = "italy/regional",
                         summary_dir = "italy/regional-summary",
                         target_date = "latest",
                         region_scale = "Region")


# Save summary csv --------------------------------------------------------

source(here::here("utils/save_summary_csv.R"))


save_summary_csv(results_dir = "italy/regional",
                 summary_dir = "italy/regional-summary",
                 type = "region")
