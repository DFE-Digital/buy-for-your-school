EXCLUDED_DEV_JOBS = %w[synchronize_shared_inbox resync_email_ids].freeze

Sidekiq.configure_server do |config|
  config.redis = { url: "#{ENV['REDIS_URL']}/0" }

  # Sidekiq Cron
  schedule_file = "config/schedule.yml"
  if File.exist?(schedule_file)
    schedule = YAML.load_file(schedule_file)
    schedule.except!(*EXCLUDED_DEV_JOBS) if Rails.env.development?

    Sidekiq::Cron::Job.destroy_all!
    Sidekiq::Cron::Job.load_from_hash(schedule)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: "#{ENV['REDIS_URL']}/0" }
end
