#### Preamble ####
# Purpose: Cleans the raw sourdough bread price data
# Author: Grace Nguyen
# Date: November 25 2024
# Contact: hagiang.nguyen@mail.utoronto.ca
# License: MIT
# Pre-requisites: 02-download_data.R must be run first

#### Workspace setup ####
library(tidyverse)
library(here)
library(arrow)

#### Clean data ####
raw_data <- read_csv(here("data", "01-raw_data", "raw_sourdough_prices.csv"))

cleaned_data <- raw_data %>%
  janitor::clean_names() %>%
  # Clean column names
  rename(
    price_per_100g = price_per_100g
  ) %>%
  # Remove any remaining NAs
  drop_na() %>%
  # Arrange by date
  arrange(date)

#### Save data ####
write_parquet(cleaned_data, here("data", "02-analysis_data", "analysis_data.parquet"))
