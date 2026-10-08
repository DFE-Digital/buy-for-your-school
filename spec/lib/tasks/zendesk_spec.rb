require "rails_helper"

RSpec.describe "Zendesk tasks" do
  before do
    Rake.application.rake_require("tasks/zendesk")
    Rake::Task.define_task(:environment)
  end

  after do
    Rake::Task["zendesk:ticket_forms"].reenable
    Rake::Task["zendesk:ticket_form_fields"].reenable
    Rake::Task["zendesk:create_test_ticket"].reenable
  end

  it "prints the available ticket forms" do
    response = [{ "id" => 456, "name" => "General enquiries", "active" => true }]
    expected_output = [{ "id" => 456, "name" => "General enquiries" }]
    client = instance_double(Zendesk::Client, ticket_forms: response)
    allow(Zendesk::Client).to receive(:new).and_return(client)

    expect { Rake::Task["zendesk:ticket_forms"].invoke }
      .to output("#{JSON.pretty_generate(expected_output)}\n")
      .to_stdout
    expect(client).to have_received(:ticket_forms)
  end

  it "prints the fields returned for a form" do
    response = { "ticket_form" => { "id" => 456 }, "ticket_fields" => [{ "id" => 1 }] }
    client = instance_double(Zendesk::Client, ticket_form_fields: response)
    allow(Zendesk::Client).to receive(:new).and_return(client)

    expect { Rake::Task["zendesk:ticket_form_fields"].invoke(456) }
      .to output("#{JSON.pretty_generate(response)}\n")
      .to_stdout
    expect(client).to have_received(:ticket_form_fields).with(ticket_form_id: 456)
  end

  it "creates a test ticket for the register your interest form" do
    client = instance_double(Zendesk::Client, create_ticket: 789)
    allow(Zendesk::Client).to receive(:new).and_return(client)

    expect { Rake::Task["zendesk:create_test_ticket"].invoke }
      .to output("Created Zendesk test ticket 789.\n")
      .to_stdout

    expect(client).to have_received(:create_ticket).with(
      subject: start_with("Register your interest test - "),
      comment: "Test ticket created by the Zendesk rake task.",
      ticket_form_id: 35_484_269_639_570,
      custom_fields: contain_exactly(
        include(id: 346_773_793_054_90, value: a_string_matching(/\A\d{10}\z/)),
        include(id: 346_775_177_040_82, value: a_string_matching(/\A\d{4}-\d{2}-\d{2}\z/)),
        include(id: 346_775_457_152_18, value: a_string_matching(/\A\d{4}-\d{2}-\d{2}\z/)),
        { id: 354_839_518_846_90, value: "yes_change" },
        { id: 354_840_302_313_14, value: "yes_change_elec" },
        include(id: 354_841_419_654_58, value: a_string_matching(/\A\d{8}\z/)),
        include(id: 37_977_986_359_570, value: a_kind_of(String)),
      ),
    )
  end
end
