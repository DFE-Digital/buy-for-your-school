require "rails_helper"
require "vcap_parser"

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
        described_class.load_service_environment_variables!
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
        described_class.load_service_environment_variables!
        expect(ENV["REDIS_URL"]).to eq("rediss://x:REDACTED@HOST:6379")
      end
    end

    it "does not error if VCAP_SERVICES is not set" do
      ClimateControl.modify VCAP_SERVICES: nil do
        expect { described_class.load_service_environment_variables! }.not_to raise_error
      end
    end
  end

  it "sets the s3 environment variables" do
    vcap_json = '{
       "aws-s3-bucket": [
        {
         "binding_name": null,
         "credentials": {
          "aws_access_key_id": "XXXXXXXXXXXXXXXXXXXX",
          "aws_region": "eu-west-2",
          "aws_secret_access_key": "XXXX/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
          "bucket_name": "paas-s3-broker-prod-lon-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
          "deploy_env": ""
         },
         "instance_name": "my-bucket",
         "label": "aws-s3-bucket",
         "name": "my-bucket",
         "plan": "default",
         "provider": null,
         "syslog_drain_url": null,
         "tags": [
          "s3"
         ],
         "volume_mounts": []
        }
       ]
      }
    '
    ClimateControl.modify VCAP_SERVICES: vcap_json do
      described_class.load_service_environment_variables!
      expect(ENV["AWS_ACCESS_KEY_ID"]).to eq("XXXXXXXXXXXXXXXXXXXX")
      expect(ENV["AWS_REGION"]).to eq("eu-west-2")
      expect(ENV["AWS_SECRET_ACCESS_KEY"]).to eq("XXXX/XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
      expect(ENV["BUCKET_NAME"]).to eq("paas-s3-broker-prod-lon-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX")
    end
  end
end
