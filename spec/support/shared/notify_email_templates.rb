RSpec.shared_context "with notify email templates" do
  let(:available_email_templates) do
    [
      instance_double("Notifications::Client::Template", id: "1", name: "What is a framework?",
        body: "Hi ((toName)), here is information regarding frameworks"
      ),
      instance_double("Notifications::Client::Template", id: "2", name: "How to approach suppliers"),
      instance_double("Notifications::Client::Template", id: "3", name: "Catering frameworks"),
      instance_double("Notifications::Client::Template", id: "4", name: "Social value"),
    ]
  end

  before do
    allow_any_instance_of(Notifications::Client).to receive(:get_all_templates)
      .with(include(type: "email"))
      .and_return(instance_double("Notifications::Client::TemplateCollection", collection: available_email_templates))
  end
end
