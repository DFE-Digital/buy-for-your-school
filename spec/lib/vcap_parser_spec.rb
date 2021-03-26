require "rails_helper"

RSpec.describe VcapParser do
  describe ".load_service_environment_variables!" do
    it "loads service level environment variables to the ENV" do
      vcap_json = '
        {
           "user-provided": [
            {
             "credentials": {
              "ENV1": "ENV1VALUE",
              "ENV2": "ENV2VALUE"
             }
            }
           ]
         }
      '
      ClimateControl.modify VCAP_SERVICES: vcap_json do
        VcapParser.load_service_environment_variables!
        expect(ENV["ENV2"]).to eq("ENV2VALUE")
      end
    end

    it "loads redis URL to the ENV" do
      vcap_json = '
        {
          "redis": [
           {
              "credentials": {
                "uri": "rediss://x:REDACTED@HOST:6379"
              }
            }
          ]
        }
      '
      ClimateControl.modify VCAP_SERVICES: vcap_json do
        VcapParser.load_service_environment_variables!
        expect(ENV["REDIS_URL"]).to eq("rediss://x:REDACTED@HOST:6379")
      end
    end

    it "does not error if VCAP_SERVICES is not set" do
      ClimateControl.modify VCAP_SERVICES: nil do
        expect { VcapParser.load_service_environment_variables! }.to_not raise_error
      end
    end
  end
end
