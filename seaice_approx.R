library(dplyr)
library(readr)
import::from(magrittr, "%$%")

N_seaice_extent <- read_csv("ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/north/daily/data/N_seaice_extent_daily_v2.1.csv",
                            col_names = c("Year", "Month", "Day", "Extent"),
                            col_types = "iiid__", skip = 2) %>%
  mutate(Date = lubridate::make_date(Year, Month, Day))

seaice_approx <- N_seaice_extent %$%
  approx(Date, Extent, seq(min(Date), max(Date), by = "days")) %>%
  as_tibble() %>%
  rename(Date = x, Extent = y)
