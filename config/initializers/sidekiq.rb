require "yaml"

# Middleware to ensure proper error handling
class JobDefinitionMiddleware
  def call(worker, job, queue)
    yield
  rescue NameError => e
    Rails.logger.error("NameError in Sidekiq job: #{e.message}")
    raise
  end
end

redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  config.server_middleware do |chain|
    chain.add JobDefinitionMiddleware
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

Rails.application.config.active_job.queue_adapter = :sidekiq
