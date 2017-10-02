class RateLimit
  DEFAULT_RATE_LIMIT_COUNT = 100
  DEFAULT_RATE_LIMIT_PERIOD = 3600

  def initialize(app, opts = {})
    @app = app
    @options = default_options.merge(opts.delete_if { |key, value| value.blank? })
    @cache = Rails.cache
  end

  def call(env)
    req = Rack::Request.new(env)

    if reqest_path_not_limit?(req)
      clear_cache(req) if cache_count(req) && period_expired?(req)
      call_app_with_rate_limit(req, env)
    else
      app.call(env)
    end
  end

  private

  attr_reader :app, :cache, :options

  def default_options
    {
      rate_limit: DEFAULT_RATE_LIMIT_COUNT,
      rate_period: DEFAULT_RATE_LIMIT_PERIOD,
      controllers: []
    }
  end

  def reqest_path_not_limit?(req)
    options[:controllers].include?(controller(req))
  end

  def controller(req)
    matched = %r{^\/?(\w+)\/?}.match(req.path)
    matched && matched[1]
  end

  def call_app_with_rate_limit(req, env)
    init_or_increase_cache(req)

    if cache_count(req) > options[:rate_limit].to_i
      response_too_many_request(req)
    else
      app.call(env)
    end
  end

  def cache_count(req)
    cache.read(cache_key_count(req))
  end

  def cache_key_count(req)
    "rate_limit:#{req.ip}:#{controller(req)}:count"
  end

  def cache_key_expire_at(req)
    "rate_limit:#{req.ip}:#{controller(req)}:expire_at"
  end

  def response_too_many_request(req)
    [429, default_content_type, response_message(req)]
  end

  def default_content_type
    { 'Content-Type' => 'text/plain' }
  end

  def init_or_increase_cache(req)
    increment_to = cache.increment(cache_key_count(req))
    return if increment_to
    cache.write(cache_key_count(req), 1)
    cache.write(cache_key_expire_at(req), Time.now.to_i + options[:rate_period].to_i - 1)
  end

  def clear_cache(req)
    cache.delete(cache_key_count(req))
    cache.delete(cache_key_expire_at(req))
  end

  def period_expired?(req)
    expired_in(req) < 0
  end

  def expired_in(req)
    cache.read(cache_key_expire_at(req)) - Time.now.to_i
  end

  def response_message(req)
    [
      "Rate limit exceeded. Try again in #{expired_in(req)} seconds"
    ]
  end
end
