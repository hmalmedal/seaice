library(tidyverse)
library(magrittr)

url <- "ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/north/daily/data/N_seaice_extent_daily_v3.0.csv"
col_names <- c("Year", "Month", "Day", "Extent", "Missing", "Source Data")
col_types <- cols(
  .default = col_double(),
  `Source Data` = col_character()
)

N_seaice_extent <- read_csv(url, col_names = col_names, col_types = col_types,
                            skip = 2) %>%
  mutate(Date = lubridate::make_date(Year, Month, Day))

seaice_approx <- N_seaice_extent %$%
  approx(Date, Extent, seq(min(Date), max(Date), by = "days")) %>%
  as_tibble() %>%
  rename(Date = x, Extent = y)
