redis_session_uri = URI(ENV.fetch("REDIS_URL"))

BuyForYourSchool::Application.config.session_store :redis_store,
  servers: ["#{redis_session_uri}/0/session"],
  expire_after: 1.day,
  key: "_buy_for_your_school_session",
  threadsafe: true,
  secure: Rails.env.production?
