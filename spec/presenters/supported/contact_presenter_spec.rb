require "rails_helper"

RSpec.describe Support::ContactPresenter do
  describe "#name" do
    it "returns the full name" do
      contact = Support::Contact.find_by
      # contact = create(:contact, first_name: 'foo', last_name: 'bar')

      presenter = described_class.new(contact)
      expect(presenter.name).to eq('John Wick')
    end
  end
end
