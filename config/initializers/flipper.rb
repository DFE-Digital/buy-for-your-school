if Rails.env.test?
  Rails.application.configure do
    config.flipper.memoize = false
  end
end

# Add feature flag decllarations here
