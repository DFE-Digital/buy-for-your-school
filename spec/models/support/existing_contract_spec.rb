require 'rails_helper'

RSpec.describe ExistingContract, type: :model do
  it { should have_one(:support_case) }
end
