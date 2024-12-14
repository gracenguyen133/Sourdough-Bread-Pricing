#### Preamble ####
# Purpose: Explores patterns in sourdough bread pricing across vendors and time
# Author: Grace Nguyen
# Date: November 25 2024
# Contact: hagiang.nguyen@mail.utoronto.ca
# License: MIT
# Pre-requisites: 03-clean_data.R must be run

#### Workspace setup ####
library(tidyverse)
library(arrow)
library(lubridate)
library(modelsummary)

#### Read data ####
analysis_data <- read_parquet(here("data", "02-analysis_data", "analysis_data.parquet"))

#### Initial exploration ####
# Summary statistics
price_summary <- datasummary(
  price_per_100g + price + grams ~ Mean + SD + Min + Max,
  data = analysis_data
)

# Vendor patterns
vendor_patterns <- analysis_data %>%
  group_by(vendor) %>%
  summarise(
    avg_price = mean(price_per_100g),
    products = n_distinct(product),
    price_range = max(price_per_100g) - min(price_per_100g)
  )

# Time trends
time_analysis <- analysis_data %>%
  group_by(date) %>%
  summarise(
    daily_avg = mean(price_per_100g),
    daily_sd = sd(price_per_100g)
  )

#### Visualizations ####
# Vendor price distribution
vendor_plot <- ggplot(analysis_data, aes(x = vendor, y = price_per_100g, fill = vendor)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Price Distribution by Vendor",
       x = "Vendor",
       y = "Price per 100g ($)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Time series with confidence interval
time_plot <- ggplot(time_analysis, aes(x = date, y = daily_avg)) +
  geom_line() +
  geom_ribbon(aes(ymin = daily_avg - daily_sd, 
                  ymax = daily_avg + daily_sd), 
              alpha = 0.2) +
  theme_minimal() +
  labs(title = "Average Daily Price Trends",
       x = "Date",
       y = "Average Price per 100g ($)")

#### Print Results ####
print("Summary Statistics:")
print(price_summary)

print("\nVendor Analysis:")
print(vendor_patterns)

print("\nTime Analysis Summary:")
summary(time_analysis)

print(vendor_plot)
print(time_plot)

#### Save results ####
dir.create(here("models"), recursive = TRUE, showWarnings = FALSE)
saveRDS(price_summary, here("models", "price_summary.rds"))
saveRDS(vendor_patterns, here("models", "vendor_patterns.rds"))
saveRDS(time_analysis, here("models", "time_analysis.rds"))
saveRDS(vendor_plot, here("models", "vendor_plot.rds"))
saveRDS(time_plot, here("models", "time_plot.rds"))
