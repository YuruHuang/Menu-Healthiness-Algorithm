# Load Libraries
library(readr)
library(dplyr)
library(data.table)
library(ggplot2)
library(MASS)
library(broom)

# Read Data
uhr <- read_csv('supplementary.csv')

# Original Model with all columns
original_model_fit <- function(data){
  full_model <- lm(`Expert health score` ~ ., data = data[3:18])
  step_model <- stepAIC(full_model, direction = "both", trace = FALSE)
  summary(step_model)
}

original_model_fit(uhr)

# Model after removing multi-size items
reduced_model_fit <- function(data){
  selected_columns <- c(3:4, 6:18)
  full_model <- lm(`Expert health score` ~ ., data = data[selected_columns])
  step_model <- stepAIC(full_model, direction = "both", trace = FALSE)
  summary(step_model)
}

reduced_model_fit(uhr)

# Plotting Data
plot_data <- function(data, columns){
  for (var in columns) {
    print(ggplot(data, aes(x = .data[[var]], y = `Expert health score`)) +
            geom_point() + xlab(var) +
            geom_smooth(method = "loess", col = "red", se = TRUE))
  }
}

plot_data(uhr, colnames(uhr)[4:18])

# Data Transformation
uhr <- uhr %>%
  mutate(
    specialOffers = ifelse(`Special offers` > 10, 10, `Special offers`),
    chips = ifelse(Chips > 15, 15, Chips),
    diet_r = ifelse(`Dietary requirements` > 20, 20, `Dietary requirements`),
    salads = ifelse(Salads > 20, 20, Salads)
  )

# Non-linear Model
non_linear_model_fit <- function(data){
  full_model <- lm(`Expert health score` ~ specialOffers +
                     `Smaller portions` + `Healthy/ier options` + diet_r +
                     Desserts + salads + chips + Vegetables + `Nutrition info` +
                     `Sugary drinks` + `Diet drinks` + Milk + Water + Alcohol, 
                   data = data)
  step_model <- stepAIC(full_model, direction = "both", trace = FALSE)
  summary(step_model)
}

non_linear_model_fit(uhr)

# Export Summary
export_summs(step_model, 
             ci_level = 0.95,
             error_format = "[{conf.low}, {conf.high}]",
             to.file = 'word',
             file.name = "ModifiedModel_210422.docx")


