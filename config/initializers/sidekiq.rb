Sidekiq.configure_server do |config|
  config.redis = { url: "#{ENV['REDIS_URL']}/0" }

  # Sidekiq Cron
  schedule_file = "config/schedule.yml"
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: "#{ENV['REDIS_URL']}/0" }
end

# TODO: remove this when incoming email work is to be merged
if ENV["MS_GRAPH_ENABLED"] != "1" && ENV["REDIS_URL"].present?
  # Ms graph features not enabled, do not run email tasks
  Sidekiq::Cron::Job.destroy "synchronize_shared_inbox"
end
