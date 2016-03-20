library(readr)
library(stringr)
library(dplyr)
import::from(magrittr, "%$%")

NH_seaice_extent_final <- "ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/north/daily/data/NH_seaice_extent_final.csv"
NH_seaice_extent_nrt <- "ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/north/daily/data/NH_seaice_extent_nrt.csv"
NH <- c(NH_seaice_extent_final, NH_seaice_extent_nrt)

NH_seaice_extent <- lapply(NH, read_csv,
                           col_names = c("Year", "Month", "Day", "Extent"),
                           col_types = "nnnn__", skip = 2) %>%
  bind_rows() %>%
  mutate(Date = as.Date(str_c(Year, Month, Day, sep = "-")))

seaice_approx <- NH_seaice_extent %$%
  approx(Date, Extent, seq(min(Date), max(Date), by = "days")) %>%
  as_data_frame() %>%
  rename(Date = x, Extent = y)
