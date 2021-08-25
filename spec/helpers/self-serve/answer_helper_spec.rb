require "rails_helper"

RSpec.describe AnswerHelper, type: :helper do
  describe "#human_readable_option" do
    it "replaces underscores with spaces and capitalises the string" do
      result = helper.human_readable_option(string: "a_hash_key")
      expect(result).to eql("A hash key")
    end
  end

  describe "#machine_readable_option" do
    it "replaces spaces with underscores, removes special characters and downcases the string" do
      result = helper.machine_readable_option(string: "A LONG key with inconsistent casing &*()%$")
      expect(result).to eql("a_long_key_with_inconsistent_casing")
    end
  end
end
