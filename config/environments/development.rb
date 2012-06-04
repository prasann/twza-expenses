Mankatha::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  # Raise exception on mass assignment protection for Active Record models
  #config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  #config.active_record.auto_explain_threshold_in_seconds = 0.5

  config.after_initialize do
    # config.action_controller.asset_host =  Proc.new { |source, request|
    #   "#{request.protocol}#{request.host}:#{request.port}"
    # }
    # config.action_mailer.asset_host = "http://#{AppConstants.ASSET_HOST}:#{AppConstants.HTTP_PORT}"

    # TODO: Even though we set the 'config.action_controller.asset_host' above, it doesnt seem to have an effect
    # This might be specific to this version of rails 3.1 - since all online help blogs say that this works for 3.2
    # ActionController::Base.asset_host = Proc.new { |source, request|
    #   "#{request.protocol}#{request.host}:#{request.port}"
    # }

    if defined?(::Bullet)
      Bullet.enable = true
      # Bullet.alert = true
      Bullet.bullet_logger = true
      Bullet.console = true
      # Bullet.growl = true
      Bullet.rails_logger = false
      Bullet.disable_browser_cache = true
    end

    if should_load_non_rake_gems
      stdin, stdout, stderr = Open3.popen3('mailcatcher')
      output = stdout.readlines.join
      error = stderr.readlines.join
      Rails.logger.info(output) unless output.blank? if Rails.logger
      Rails.logger.info(error) unless error.blank? if Rails.logger
    end
  end
end
