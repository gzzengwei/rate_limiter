require 'dotenv'
Dotenv.load

Rails.application.config.middleware.use(
  RateLimit,
  rate_limit: ENV['RATE_LIMIT_COUNT'],
  rate_period: ENV['RATE_LIMIT_PERIOD'],
  controllers: %w(home)
)
