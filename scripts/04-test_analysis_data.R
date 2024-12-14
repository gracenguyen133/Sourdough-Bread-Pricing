#### Preamble ####
# Purpose: Tests the cleaned sourdough price dataset
# Author: Grace Nguyen
# Date: November 25 2024
# Contact: hagiang.nguyen@mail.utoronto.ca
# License: MIT
# Pre-requisites: 03-clean_data.R must be run first

#### Workspace setup ####
library(tidyverse)
library(testthat)
library(arrow)

analysis_data <- read_parquet(here("data", "02-analysis_data", "analysis_data.parquet"))

#### Test data ####
test_that("data structure is correct", {
  expect_equal(ncol(analysis_data), 7)
  expect_true(all(c("date", "vendor", "product", "brand", "price", "grams", "price_per_100g") %in% names(analysis_data)))
})

test_that("data types are correct", {
  expect_type(analysis_data$date, "double") # Date stored as double
  expect_type(analysis_data$vendor, "character")
  expect_type(analysis_data$product, "character")
  expect_type(analysis_data$brand, "character")
  expect_type(analysis_data$price, "double")
  expect_type(analysis_data$grams, "double")
  expect_type(analysis_data$price_per_100g, "double")
})

test_that("no missing values in dataset", {
  expect_true(all(!is.na(analysis_data)))
})

test_that("values are within valid ranges", {
  expect_true(all(analysis_data$price > 0))
  expect_true(all(analysis_data$grams > 0))
  expect_true(all(analysis_data$price_per_100g > 0))
})

valid_vendors <- c("Loblaws", "Metro", "NoFrills", "Walmart", "Voila")
test_that("vendor names are valid", {
  expect_true(all(analysis_data$vendor %in% valid_vendors))
})

test_that("dates are within expected range", {
  expect_true(all(analysis_data$date >= as.Date("2024-02-28")))
  expect_true(all(analysis_data$date <= as.Date("2024-07-05")))
})
