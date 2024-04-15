# Kaggle Housing Price Prediction: Model Stacking

This repository contains the code and results of a Kaggle competition for predicting housing prices using model stacking. The solution utilizes three models: Random Forest, L2 Tree Boosting, and Penalized Linear Regression, combined using model stacking to improve prediction accuracy.

## Kaggle Competition Details

- Kaggle User Name: JamesCaldwell1
- Best Score: 0.14824 (Ranked 2290)

## Project Structure

- **data/**: Contains the training and test datasets (`train.csv` and `test.csv`).
- **src/**: Contains the R scripts for data cleaning, model training, and prediction.
  - `main.R`: Main script for running the entire pipeline.
  - `rf_model.R`: Script for building and saving the Random Forest model.
  - `l2_boosting_model.R`: Script for building and saving the L2 Tree Boosting model.
  - `lr_model.R`: Script for building and saving the Penalized Linear Regression model.
  - `model_stacking.R`: Script for combining predictions from the individual models using model stacking.
- **results/**: Contains the output CSV files with predictions.
  - `Z1_rf.csv`: Random Forest predictions.
  - `Z2_L2.csv`: L2 Tree Boosting predictions.
  - `Z3_lr.csv`: Penalized Linear Regression predictions.
  - `Caldwell.csv`: Stacked predictions.

## Usage

1. Clone this repository to your local machine.
2. Navigate to the `src/` directory.
3. Execute the `main.R` script to run the entire pipeline.

## Notes

- The `main.R` script orchestrates the entire process, including data cleaning, model training, prediction, and model stacking.
- Each model's performance is evaluated individually before combining them through model stacking.
- The `model_stacking.R` script implements a simple weighted averaging approach to combine predictions from the individual models.
- For further improvements, one can explore more sophisticated model stacking techniques and hyperparameter tuning.

## Results

The final predictions are stored in the `Caldwell.csv` file in the `results/` directory.

