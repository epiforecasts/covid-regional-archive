# covid-regional-archive

> **Archived.** No longer maintained; last updated June 2020. It depends on the retired `EpiNow` and `NCoVUtils` packages and on national data sources as published at the time.

Original results store for the subnational Rt estimates shown on the epiforecasts COVID-19 website, split out of epiforecasts/covid in April 2020 and used as its submodule. Germany, Italy, the United Kingdom and the United States were covered from the start, with Brazil and India added in May 2020. In June 2020 it was replaced by epiforecasts/covid-regional, a new repository with its own history; this repository keeps the April to June 2020 runs.

- `update_nowcasts.sh`: updates the shared reporting delay (`update_delay.R`, saved as `delays.rds`) and runs each country's `update_nowcasts.R`.
- `<country>/regional/`: per-region estimates and plots.
- `<country>/regional-summary/`: country summary tables and plots.
- `<country>/data/`: region codes and boundary files for the maps.
