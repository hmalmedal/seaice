NH_seaice_extent_final <- read.csv("ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/north/daily/data/NH_seaice_extent_final.csv",
                                   header = F, skip = 2)
NH_seaice_extent_nrt <- read.csv("ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/north/daily/data/NH_seaice_extent_nrt.csv",
                                 header = F, skip = 2)
NH_seaice_extent <- rbind(NH_seaice_extent_final,
                          NH_seaice_extent_nrt)
names(NH_seaice_extent) <- c("Year", "Month", "Day", "Extent", "Missing",
                             "Source.Data")

library(dplyr, warn.conflicts = F)
seaice <- NH_seaice_extent %>%
  tbl_df %>%
  mutate(Date = as.Date(paste(Year, Month, Day, sep = "-"))) %>%
  filter(Date != as.Date("1984-09-14")) %>% # Bad datapoint
  select(Date, Extent)

dates <- seq(min(seaice$Date), max(seaice$Date), by = "days")

seaice_approx <- approx(seaice$Date, seaice$Extent, dates)
seaice_approx <- data.frame(Date = seaice_approx$x, Extent = seaice_approx$y)
