# ---
# title: "Model Stacking for Kaggle"
# author: "James Caldwell"
# date: "`r Sys.Date()`"
# output: html_document
# ---

# # Kaggle Housing Price Prediction: Model Stacking

# This repository contains the code and results of a Kaggle competition for predicting housing prices using model stacking. The solution utilizes three models: Random Forest, L2 Tree Boosting, and Penalized Linear Regression, combined using model stacking to improve prediction accuracy.

# ## Kaggle Competition Details

# - Kaggle User Name: JamesCaldwell1
# - Best Score: 0.14824 (Ranked 2290), goal was < 0.5 RMSE.

# ## Project Structure

# - **data/**: Contains the training and test datasets (`train.csv` and `test.csv`).
# - **src/**: Contains the R scripts for data cleaning, model training, and prediction.
#   - `main.R`: Main script for running the entire pipeline.
#   - `rf_model.R`: Script for building and saving the Random Forest model.
#   - `l2_boosting_model.R`: Script for building and saving the L2 Tree Boosting model.
#   - `lr_model.R`: Script for building and saving the Penalized Linear Regression model.
#   - `model_stacking.R`: Script for combining predictions from the individual models using model stacking.
# - **results/**: Contains the output CSV files with predictions.
#   - `Z1_rf.csv`: Random Forest predictions.
#   - `Z2_L2.csv`: L2 Tree Boosting predictions.
#   - `Z3_lr.csv`: Penalized Linear Regression predictions.
#   - `Caldwell.csv`: Stacked predictions.

# The final predictions are stored in the `Caldwell.csv` file in the `results/` directory.

# My solution uses model stacking of 3 models: random forests, L2 tree boosting,
# and penalized linear regression.

suppressWarnings({
  library(readr)
  library(glmnet)
  library(tidyverse)
  library(ranger)
  library(janitor)
  library(dplyr)
})

# Load Data
train = read_csv('train.csv') #%>% clean_names()
test = read_csv('test.csv') #%>% clean_names()

## Data Cleaning
# Cleaning train data
# Impute missing values for numeric columns with the mean
numeric_cols <- sapply(train, is.numeric)
train[ , numeric_cols] <- lapply(train[, numeric_cols], function(x) ifelse(is.na(x), mean(x, na.rm = TRUE), x))
# Impute missing values for categorical columns with the mode
categorical_cols <- sapply(train, function(x) !is.numeric(x))
train[ , categorical_cols] <- lapply(train[, categorical_cols], function(x) ifelse(is.na(x), names(sort(table(x), decreasing = TRUE))[1], x))

# Cleaning test data
# Impute missing values for numeric columns with the mean
numeric_cols <- sapply(test, is.numeric)
test[, numeric_cols] <- lapply(test[, numeric_cols], function(x) ifelse(is.na(x), mean(x, na.rm = TRUE), x))
# Impute missing values for categorical columns with the mode
categorical_cols <- sapply(test, function(x) !is.numeric(x))
test[, categorical_cols] <- lapply(test[, categorical_cols], function(x) ifelse(is.na(x), names(sort(table(x), decreasing = TRUE))[1], x))

X = glmnet::makeX(select(train, -SalePrice), test)
X.train = X$x
X.test = X$xtest
Y.train = as.data.frame(train$SalePrice)
colnames(Y.train) <- "SalePrice"

# print(head(X.train))

# Model #1: Random Forest
# # MODEL #1: Random Forest
rf_model <- ranger(SalePrice ~ ., data = train)
# # Make predictions
Z1_rf <- predict(rf_model, data = test)$predictions

# # Combine predictions and the X Test Id column
Z1_rf_csv <- cbind(Id = X.test[, "Id", drop = FALSE], SalePrice = Z1_rf)

# # Write the submission data to a CSV file
write.csv(Z1_rf_csv, file = "Z1_rf.csv", row.names = FALSE)

# Model #2: L2 Tree Boosting
# library(gbm)

gbm_train = cbind(X.train,Y.train)

# # Initialize the gradient boosting model
gbm_model <- gbm(
  formula = SalePrice ~ .,  
  data = gbm_train,  
  distribution = "gaussian",  # For regression
  n.trees = 100,  # Number of boosting iterations
  interaction.depth = 3,  # Maximum depth of each tree
  shrinkage = 0.1,  # Learning rate
  bag.fraction = 0.5,  # Fraction of observations to be used for each tree
  train.fraction = 1,  # Fraction of data to be used for training (1 for using all data)
  n.minobsinnode = 10,  # Minimum number of observations in terminal nodes
  verbose = TRUE  # To see the progress of training
)

# # Make predictions on the test set
Z2_L2 <- predict(gbm_model, newdata = as.data.frame(X.test), n.trees = 100)  # Assuming your test data is in a data frame called test_data

# # Combine Id column from X.test with Z2_L2 predictions
Z2_L2_csv <- cbind(Id = X.test[, "Id", drop = FALSE], SalePrice = Z2_L2)

# # Write the submission data to a CSV file
write.csv(Z2_L2_csv, file = "Z2_L2.csv", row.names = FALSE)

# Model #3: (penalized) linear regression
# library(glmnet)
set.seed(2023)

# # str(X.train)
# # str(Y.train)
g2 = cv.glmnet(X.train, Y.train$SalePrice) # tune lambda with 10-fold cv
Z3_lr = predict(g2, X.test, s = "lambda.min") # choose lambda.min

# # print(Z2_lr)
# # Assign custom column names
colnames(Z3_lr) <- ("SalePrice")

write.csv(Z3_lr, file = "Z3_lr.csv", row.names = TRUE)

# Use Model stacking to aggregate RF, L2 boosting, and LM. <br>

# Here, I use a simple weighted averaging to assemble the final model. Since the
# 1st two models performed better than the LR model, I'll assign a higher weight
# to those models

# If I was to spend more time on this, I would probably use hold out data with 
# cross validation to improve my model performance and get better estimates for
# the weights to use
# # average_predictions <- (Z1_rf + Z2_L2 + Z3_lr) / 3 #This is pure averaging 
# # which I ended up not using
average_predictions <- (Z1_rf*.4 + Z2_L2*.4 + Z3_lr*.2)

# # Combine Id column from X.test with Z2_L2 predictions
yhat_stacked <- cbind(Id = X.test[, "Id", drop = FALSE], SalePrice = average_predictions)

# # Write the submission data to a CSV file
write.csv(yhat_stacked, file = "Caldwell.csv", row.names = FALSE)

