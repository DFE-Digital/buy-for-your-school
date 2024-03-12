require "rails_helper"

describe FrameworkRequest::Validatable do
  subject(:validatable) { build(:framework_request) }

  it { is_expected.to validate_presence_of(:first_name).on(:complete).with_message("Enter your first name") }
  it { is_expected.to validate_presence_of(:last_name).on(:complete).with_message("Enter your last name") }
  it { is_expected.to validate_presence_of(:email).on(:complete).with_message("Enter your email address") }
  it { is_expected.to validate_presence_of(:org_id).on(:complete).with_message("Select the school or group you want help buying for") }
  it { is_expected.to validate_presence_of(:message_body).on(:complete).with_message("You must tell us how we can help") }
  it { is_expected.to validate_presence_of(:procurement_amount).on(:complete).with_message("Enter how much the school will be spending. The number must be greater than 0.") }
  it { is_expected.to validate_presence_of(:category).on(:complete).with_message("Select the type of goods or service you need") }
  it { is_expected.to validate_presence_of(:origin).on(:complete).with_message("Select where you heard about the service") }
end
