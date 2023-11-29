Sidekiq.configure_server do |config|
  config.redis = { url: "#{ENV['REDIS_URL']}/0" }

  # Sidekiq Cron
  schedule_file = "config/schedule.yml"
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.destroy_all!
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: "#{ENV['REDIS_URL']}/0" }
end
