#### Preamble ####
# Purpose: Simulate sourdough bread price data matching the structure of real market data
# Author: Grace Nguyen
# Date: November 25 2024
# Contact: hagiang.nguyen@mail.utoronto.ca
# License: MIT
# Pre-requisites: The ‘tidyverse’ and ‘here’ packages must be installed

#### Workplace setup ####
library(tidyverse)
library(here)

set.seed(853)

# Create directory
dir.create(here("data", "00-simulated_data"), recursive = TRUE, showWarnings = FALSE)

# Calculate number of days
date_range <- seq(as.Date("2024-02-28"), as.Date("2024-07-05"), by="day")
n_days <- length(date_range)

# Simulate data
sim_data <- tibble(
  date = date_range,
  vendor = sample(c("Loblaws", "Metro", "NoFrills", "Walmart", "Voila"), n_days, replace=TRUE),
  price = rnorm(n_days, mean=4.50, sd=1),
  grams = sample(c(450, 500, 550, 585, 650, 675, 800), n_days, replace=TRUE),
  price_per_100g = price/(grams/100)
)

# Add explicit type specification for date
write_csv(sim_data, here("data", "00-simulated_data", "simulated_sourdough_prices.csv"))
