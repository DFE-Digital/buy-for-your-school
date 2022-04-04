require "support/frameworks/mapper"

RSpec.describe Support::Frameworks::Mapper, "#call" do
  subject(:mapper) { described_class.new }

  let(:entity) { output.first[key] }

  let(:output) do
    mapper.call(
      [
        "Framework" => "Catering services",
        "FWK Provider" => "ABC",
        "FAF Category Group" => "Catering",
        "Initial Expiry Date on FaF" => "2023-04-15",
      ],
    )
  end

  describe "name" do
    let(:key) { :name }

    specify do
      expect(entity).to eql("Catering services")
    end
  end

  describe "supplier" do
    let(:key) { :supplier }

    specify do
      expect(entity).to eql("ABC")
    end
  end

  describe "category" do
    let(:key) { :category }

    specify do
      expect(entity).to eql("Catering")
    end
  end

  describe "expires_at" do
    let(:key) { :expires_at }

    specify do
      expect(entity).to eql("2023-04-15")
    end
  end
end
