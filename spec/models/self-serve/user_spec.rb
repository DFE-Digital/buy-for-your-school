require "rails_helper"

RSpec.describe User, type: :model do
  it "store the user's DfE Sign-in UID" do
    user = build(:user, dfe_sign_in_uid: "a96ee522-2de8-4eb1-9b17-9619a310149b")
    expect(user.dfe_sign_in_uid).to eql("a96ee522-2de8-4eb1-9b17-9619a310149b")
  end
end
