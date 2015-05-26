library(readr)
library(stringr)
library(dplyr)
read_seaice <- function(file)
  read_csv(file) %>%
  slice(-1) %>%
  `names<-`(str_trim(names(.))) %>%
  mutate_each(funs(str_trim)) %>%
  mutate(Date = str_c(Year, Month, Day, sep = "-")) %>%
  type_convert()
NH_seaice_extent_final <- "ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/north/daily/data/NH_seaice_extent_final.csv"
NH_seaice_extent_nrt <- "ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/north/daily/data/NH_seaice_extent_nrt.csv"
NH_seaice_extent <- rbind(read_seaice(NH_seaice_extent_final),
                          read_seaice(NH_seaice_extent_nrt))

seaice <- NH_seaice_extent %>%
  select(Date, Extent)

dates <- seq(min(seaice$Date), max(seaice$Date), by = "days")

seaice_approx <- approx(seaice$Date, seaice$Extent, dates)
seaice_approx <- data_frame(Date = seaice_approx$x, Extent = seaice_approx$y)
