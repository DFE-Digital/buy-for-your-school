require "rails_helper"

RSpec.describe FrameworkRequest, type: :model do
  # TODO: reinstate validations once all FaF steps are in
  xdescribe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:school_urn) }
    it { is_expected.to validate_presence_of(:message_body) }
  end

  it { is_expected.to belong_to(:user).optional }
end
