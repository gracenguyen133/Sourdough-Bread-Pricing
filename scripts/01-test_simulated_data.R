#### Preamble ####
# Purpose: Tests the structure and validity of the simulated sourdough bread price dataset
# Author: Grace Nguyen
# Date: November 25 2024
# Contact: hagiang.nguyen@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse`, `here`, and `testthat` packages must be installed and loaded
# - 00-simulate_data.R must have been run first



#### Workspace setup ####
library(tidyverse)
library(here)
library(testthat)

# Read simulated data with type conversion
sim_data <- read_csv(here("data", "00-simulated_data", "simulated_sourdough_prices.csv")) %>%
  mutate(date = as.Date(date))

# Test suite
test_that("Simulated data structure is correct", {
  # Data structure tests
  expect_equal(ncol(sim_data), 5)
  expect_equal(nrow(sim_data), length(seq(as.Date("2024-02-28"), as.Date("2024-07-05"), by="day")))
  expect_true(all(c("date", "vendor", "price", "grams", "price_per_100g") %in% names(sim_data)))
  
  # Data type tests
  expect_true(is.Date(sim_data$date))
  expect_true(is.character(sim_data$vendor))
  expect_true(is.numeric(sim_data$price))
  expect_true(is.numeric(sim_data$grams))
  expect_true(is.numeric(sim_data$price_per_100g))
  
  # Value range tests
  expect_true(all(sim_data$vendor %in% c("Loblaws", "Metro", "NoFrills", "Walmart", "Voila")))
  expect_true(all(sim_data$grams %in% c(450, 500, 550, 585, 650, 675, 800)))
  expect_true(all(sim_data$price > 0))
  expect_true(all(sim_data$price_per_100g > 0))
  
  # Calculation test
  expect_equal(sim_data$price_per_100g, sim_data$price/(sim_data$grams/100))
})