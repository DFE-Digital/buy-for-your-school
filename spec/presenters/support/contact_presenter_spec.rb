require "rails_helper"

RSpec.describe Support::ContactPresenter do
  let(:presenter) { described_class.new(OpenStruct(first_name: "foo", last_name: "bar")) }

  describe "#full_name" do
    it "returns the correctly formatted full name" do
      expect(presenter.full_name).to eq("Foo Bar")
    end
  end
end
