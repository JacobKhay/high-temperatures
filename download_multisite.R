# download_multisite.R

library(worldmet)
library(dplyr)
library(lubridate)
library(readr)

# 1. List candidate Seattle/WA stations
stations <- getMeta()
seattle_neighbourhoods <- c("SEATTLE", "TACOMA", "EVERETT", "BELLEVUE")
selected <- stations %>% 
  filter(any(sapply(seattle_neighbourhoods, grepl, station, ignore.case = TRUE))) %>%
  head(5)  # limit to 5 for manageable size

# 2. Download hourly data for July 2024 for each station
all_daily <- lapply(seq_len(nrow(selected)), function(i) {
  st <- selected[i, ]
  df <- importNOAA(
    code = paste(st$usaf, st$wban, sep = "-"),
    year = 2024,
    hourly = TRUE,
    path = tempdir()
  ) %>% 
    mutate(station = st$station) %>%
    filter(month(date) == 7)
  
  df %>%
    group_by(station, date = as.Date(date)) %>%
    summarise(tmax_C = max(air_temp, na.rm = TRUE), .groups = "drop") %>%
    mutate(tmax_F = round(tmax_C * 9/5 + 32, 1))
})

# 3. Combine and save
daily_multi <- bind_rows(all_daily)
write_csv(daily_multi, "daily_multi_july2024.csv")
