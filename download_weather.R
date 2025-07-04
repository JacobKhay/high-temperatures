# download_weather.R

# Load packages
library(worldmet)
library(dplyr)
library(lubridate)
library(readr)

# Define station and year
station_id <- "727930-24233"
year_to_download <- 2024

# Import hourly weather data
seattle_weather <- importNOAA(
  code = station_id,
  year = year_to_download,
  hourly = TRUE,
  path = tempdir()
)

# Convert to daily max temperatures for July
daily_max_temps <- seattle_weather %>%
  mutate(date = as.Date(date)) %>%
  filter(month(date) == 7) %>%
  group_by(date) %>%
  summarise(tmax_C = max(air_temp, na.rm = TRUE)) %>%
  mutate(tmax_F = round(tmax_C * 9/5 + 32, 1))

# Save to CSV in the project folder
write_csv(daily_max_temps, "daily_max_july2024.csv")
