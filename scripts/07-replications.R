#### Preamble ####
# Purpose: Replicates key visualizations of sourdough bread price analysis
# Author: Grace Nguyen
# Date: November 25 2024
# Contact: hagiang.nguyen@mail.utoronto.ca
# License: MIT
# Pre-requisites: 06-model_data.R

#### Workspace setup ####
library(tidyverse)
library(arrow)
library(modelsummary)
library(scales)

#### Load data and models ####
analysis_data <- read_parquet(here("data", "02-analysis_data", "analysis_data.parquet"))
refined_model <- readRDS(here("models", "refined_model.rds"))

#### Replicate plots ####
# 1. Improved vendor trends
vendor_trends <- ggplot(analysis_data, aes(x = date, y = price_per_100g, color = vendor)) +
  geom_smooth(method = "loess", se = TRUE, size = 1) +
  geom_hline(yintercept = mean(analysis_data$price_per_100g), 
             linetype = "dashed", alpha = 0.5) +
  facet_wrap(~ vendor) +
  scale_color_brewer(palette = "Set2") +
  scale_x_date(date_breaks = "1 month", date_labels = "%b") +
  scale_y_continuous(labels = dollar_format()) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.minor = element_blank(),
    legend.position = "none"
  ) +
  labs(
    title = "Sourdough Bread Price Trends by Vendor",
    subtitle = "Dashed line shows overall mean price",
    x = "Date",
    y = "Price per 100g ($)"
  )

# 2. Improved brand comparison
brand_summary <- analysis_data %>%
  group_by(brand) %>%
  summarise(
    n = n(),
    median_price = median(price_per_100g),
    mean_price = mean(price_per_100g)
  ) %>%
  filter(n >= 10)  # Only brands with sufficient data

# Create dataset for plotting
plot_data <- analysis_data %>%
  filter(brand %in% brand_summary$brand) %>%
  mutate(brand = factor(brand, 
                        levels = brand_summary$brand[order(brand_summary$median_price)]))

brand_comparison <- ggplot(plot_data, aes(y = brand, x = price_per_100g)) +
  geom_boxplot(outlier.color = "red", outlier.size = 1, alpha = 0.7) +
  geom_point(data = brand_summary, 
             aes(x = mean_price, y = brand),
             color = "blue", size = 2) +
  geom_text(data = brand_summary,
            aes(x = max(analysis_data$price_per_100g), 
                y = brand,
                label = paste("n =", n)),
            hjust = 1, size = 3) +
  scale_x_continuous(labels = dollar_format()) +
  theme_minimal() +
  theme(
    axis.text.y = element_text(size = 8),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "Price Distribution by Brand",
    subtitle = "Blue dots show mean prices, boxes show quartiles",
    x = "Price per 100g ($)",
    y = NULL
  )


# 3. Improved model predictions plot
predictions <- posterior_predict(refined_model)
pred_df <- data.frame(
  actual = analysis_data_clean$price_per_100g,
  predicted = colMeans(predictions)
)

rmse <- sqrt(mean((pred_df$actual - pred_df$predicted)^2))
r2 <- cor(pred_df$actual, pred_df$predicted)^2

model_fit <- ggplot(pred_df, aes(x = actual, y = predicted)) +
  geom_point(alpha = 0.5) +
  geom_abline(intercept = 0, slope = 1, color = "red", linetype = "dashed") +
  geom_smooth(method = "lm", color = "blue", se = TRUE) +
  scale_x_continuous(labels = dollar_format()) +
  scale_y_continuous(labels = dollar_format()) +
  theme_minimal() +
  labs(
    title = "Model Predictions vs Actual Prices",
    subtitle = sprintf("R² = %.3f, RMSE = $%.3f per 100g", r2, rmse),
    x = "Actual Price per 100g ($)",
    y = "Predicted Price per 100g ($)"
  )

#### Save replications ####
saveRDS(list(vendor_trends = vendor_trends,
             brand_comparison = brand_comparison,
             model_fit = model_fit),
        here("models", "replications.rds"))

# Display plots
print(vendor_trends)
print(brand_comparison)
print(model_fit)

