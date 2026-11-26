require "rails_helper"

RSpec.describe "energy:send_gas_price_updates" do
  let(:task) { Rake::Task["energy:send_gas_price_updates"] }
  let(:input_file) { "pricing.json" }
  let(:school) { { "School Name" => "Example School" } }
  let(:contact) { { "schools" => [school] } }
  let(:pricing_data) { { "contacts" => [contact] } }
  let(:email_sender) { instance_double(Energy::Emails::GasPriceUpdate, call: Object.new) }

  before do
    Rake.application.rake_require("tasks/energy/gas_price_updates")
    Rake::Task.define_task(:environment)
    task.reenable
  end

  it "requires a month argument" do
    expect { task.invoke(input_file) }
      .to raise_error(ArgumentError, /Provide a month/)
  end

  it "passes the specified month to each gas price update email" do
    allow(File).to receive(:read).with(input_file).and_return(pricing_data.to_json)
    allow(Energy::Emails::GasPriceUpdate).to receive(:new)
      .with(contact:, school:, month: "October")
      .and_return(email_sender)

    expect { task.invoke(input_file, "October") }
      .to output(/Sent gas price update for Example School/).to_stdout
  end
end
