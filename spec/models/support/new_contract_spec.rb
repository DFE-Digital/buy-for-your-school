require 'rails_helper'

RSpec.describe NewContract, type: :model do
  it { should have_one(:support_case) }
end
