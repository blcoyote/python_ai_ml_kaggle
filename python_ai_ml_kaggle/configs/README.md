# Configuration Files

Store configuration files, hyperparameters, and settings.

## Files

- Model hyperparameters (JSON/YAML)
- Pipeline configurations
- Feature engineering settings
- Cross-validation parameters

## Example

```json
{
  "model": {
    "xgboost": {
      "n_estimators": 1000,
      "learning_rate": 0.1,
      "max_depth": 6,
      "random_state": 42
    }
  },
  "cv": {
    "n_folds": 5,
    "stratified": true,
    "random_state": 42
  }
}
```
