# Loads the default configuration file located under RAILS_ROOT/config/constants.yml
# Change the default location by modifying the following line:
AppConstants.config_path = Rails.root.join("config/app_constants.yml")
AppConstants.raise_error_on_missing = true
AppConstants.load!