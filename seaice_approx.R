library(readr)
library(stringr)
library(dplyr)
library(magrittr)
read_seaice <- function(file)
  read_csv(file) %>%
  slice(-1) %>%
  set_names(str_trim(names(.))) %>%
  mutate_each(funs(str_trim)) %>%
  mutate(Date = str_c(Year, Month, Day, sep = "-")) %>%
  type_convert()
NH_seaice_extent_final <- "ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/north/daily/data/NH_seaice_extent_final.csv"
NH_seaice_extent_nrt <- "ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/north/daily/data/NH_seaice_extent_nrt.csv"
NH_seaice_extent <- rbind(read_seaice(NH_seaice_extent_final),
                          read_seaice(NH_seaice_extent_nrt))

seaice_approx <- NH_seaice_extent %$%
  approx(Date, Extent, seq(min(Date), max(Date), by = "days")) %$%
  data_frame(Date = x, Extent = y)
