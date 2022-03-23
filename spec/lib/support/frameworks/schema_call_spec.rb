require "support/frameworks/schema"

RSpec.describe Support::Frameworks::Schema, "#call" do
  subject(:schema) { described_class.new }

  let(:result) { schema.call(input) }

  let(:input) do
    {
      name: "Catering services",
      supplier: "ABC",
      category: "Catering",
      expires_at: "2023-04-15",
    }
  end

  it do
    expect(result.errors.to_h).to be_empty
  end
end
