redis_session_uri = URI(ENV.fetch("REDIS_URL", "redis://localhost:6379"))

BuyForYourSchool::Application.config.session_store :redis_store,
                                                   servers: ["#{redis_session_uri}/0/session"],
                                                   expire_after: 8.hours,
                                                   key: "_buy_for_your_school_session",
                                                   threadsafe: true,
                                                   secure: Rails.env.production?
