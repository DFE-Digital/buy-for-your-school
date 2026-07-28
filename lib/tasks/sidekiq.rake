namespace :sidekiq do
  desc "Clear all Sidekiq queues (development only)"
  task clear: :environment do
    abort("Only available in development") unless Rails.env.development?

    Sidekiq::Queue.all.to_a.each(&:clear)
    Sidekiq::ScheduledSet.new.clear
    Sidekiq::RetrySet.new.clear
    Sidekiq::DeadSet.new.clear

    puts "Sidekiq queues cleared"
  end
end
