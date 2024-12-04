#### Preamble ####
# Purpose: Models sourdough bread price variations with brand and interaction effects
# Author: Grace Nguyen
# Date: November 25 2024
# Contact: hagiang.nguyen@mail.utoronto.ca
# License: MIT
# Pre-requisites: 05-exploratory_data_analysis.R

#### Workspace setup ####
library(tidyverse)
library(arrow)
library(rstanarm)

#### Read data ####
analysis_data <- read_parquet(here("data", "02-analysis_data", "analysis_data.parquet"))

# Create product type classification
analysis_data <- analysis_data %>%
  mutate(
    product_type = case_when(
      str_detect(tolower(product), "artisan|artesano") ~ "artisan",
      str_detect(tolower(product), "sliced") ~ "sliced",
      TRUE ~ "regular"
    )
  )

# Remove outliers (prices > 3 SD from mean)
price_mean <- mean(analysis_data$price_per_100g)
price_sd <- sd(analysis_data$price_per_100g)
analysis_data_clean <- analysis_data %>%
  filter(abs(price_per_100g - price_mean) <= 3 * price_sd)

### Model data ####
refined_model <- stan_glm(
  formula = price_per_100g ~ 
    vendor * as.numeric(date) + 
    brand + 
    product_type + 
    grams,
  data = analysis_data_clean,
  family = gaussian(),
  prior = normal(location = 0, scale = 2.5, autoscale = TRUE),
  prior_intercept = normal(location = 0, scale = 2.5, autoscale = TRUE),
  prior_aux = exponential(rate = 1, autoscale = TRUE),
  seed = 853
)

# Generate predictions
predictions <- posterior_predict(refined_model)
pred_df <- data.frame(
  actual = analysis_data_clean$price_per_100g,
  predicted = colMeans(predictions)
)

# Calculate performance metrics
rmse <- sqrt(mean((pred_df$actual - pred_df$predicted)^2))
r2 <- cor(pred_df$actual, pred_df$predicted)^2

#### Model diagnostics ####
model_plot <- ggplot(pred_df, aes(x = actual, y = predicted)) +
  geom_point(alpha = 0.5) +
  geom_abline(intercept = 0, slope = 1, color = "red") +
  theme_minimal() +
  labs(
    title = "Model Predictions vs Actual Prices",
    subtitle = sprintf("R² = %.3f, RMSE = $%.3f per 100g", r2, rmse),
    x = "Actual Price per 100g ($)",
    y = "Predicted Price per 100g ($)"
  )

#### Save outputs ####
saveRDS(refined_model, here("models", "refined_model.rds"))
saveRDS(model_plot, here("models", "model_diagnostics.rds"))
saveRDS(list(rmse = rmse, r2 = r2), here("models", "performance_metrics.rds"))
