require "rails_helper"

RSpec.describe Support::Email, type: :model do
  subject(:email) { create(:support_email) }

  it { is_expected.to belong_to :case }
end
