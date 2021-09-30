# Class to parse the VCAP_SERVICES environment variable.
# Cloud Foundry provides an environment variable called VCAP_SERVICES which
# contains JSON.
# The JSON provides details of services bound to the application.
# We parse this to generate environment variables to be used by Rails.
class VcapParser
  def self.load_service_environment_variables!
    return if ENV["VCAP_SERVICES"].blank?

    vcap_json = JSON.parse(ENV["VCAP_SERVICES"])
    # Turn user provided service credentials into environment variables
    vcap_json.fetch("user-provided", []).each do |service|
      service["credentials"].each_pair do |key, value|
        ENV[key] = value
      end
    end

    load_redis_config(
      vcap_json.fetch("redis", []).first,
    )
  end

  def self.load_redis_config(redis_config)
    return unless redis_config

    # Generate a REDIS_URL from the redis service uri
    ENV["REDIS_URL"] = redis_config.fetch("credentials").fetch("uri")
  end
end
