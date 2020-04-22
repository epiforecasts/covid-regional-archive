
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
  regional_delay = FALSE
)


# Summarise results -------------------------------------------------------

EpiNow::regional_summary(results_dir = "germany/regional",
                         summary_dir = "germany/regional-summary",
                         target_date = "latest",
                         region_scale = "Region")


# Save summary csv --------------------------------------------------------

source(here::here("../../utils/save_summary_csv.R"))


save_summary_csv(results_dir = "germany/regional",
                 summary_dir = "germany/regional-summary",
                 type = "region")