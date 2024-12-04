#### Preamble ####
# Purpose: Downloads and saves the grocery price dataset from Jacob Filipp
# Author: Grace Nguyen
# Date: November 25 2024
# Contact: hagiang.nguyen@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - The `tidyverse` and `here` packages must be installed and loaded


#### Workspace setup ####
library(tidyverse)
library(here)

raw_data <- read_csv(here("data", "01-raw_data", "data-aJhFM.csv"),
                     col_types = cols(
                       Date = col_date(),
                       Vendor = col_character(),
                       Product = col_character(),
                       Brand = col_character(),
                       Price = col_double(),
                       Grams = col_double(),
                       `Price Per 100g` = col_character()
                     )) %>%
  mutate(`Price Per 100g` = case_when(
    `Price Per 100g` == "#DIV/0!" ~ NA_real_,
    TRUE ~ as.numeric(`Price Per 100g`)
  )) %>%
  filter(!is.na(Date) & Brand != "Out of stock")

# Save processed data
write_csv(raw_data, here("data", "01-raw_data", "raw_sourdough_prices.csv"))
