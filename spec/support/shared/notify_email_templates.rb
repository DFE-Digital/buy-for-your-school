RSpec.shared_context "with notify email templates" do
  let(:available_email_templates) do
    [
      instance_double("Notifications::Client::Template", id: "1", name: "What is a framework?",
        body: "Hi ((toName)), here is information regarding frameworks",
        subject: "Email subject 1"
      ),
      instance_double("Notifications::Client::Template", id: "2", name: "How to approach suppliers",
        body: "Hi ((toName)), here is information regarding approaching suppliers",
        subject: "Email subject 2"
      ),
      instance_double("Notifications::Client::Template", id: "3", name: "Catering frameworks",
        body: "Hi ((toName)), here is information regarding catering frameworks",
        subject: "Email subject 3"
      ),
      instance_double("Notifications::Client::Template", id: "4", name: "Social value",
        body: "Hi ((toName)), here is information regarding social value",
        subject: "Email subject 4"
      ),
    ]
  end

  before do
    allow_any_instance_of(Notifications::Client).to receive(:get_all_templates)
      .with(include(type: "email"))
      .and_return(instance_double("Notifications::Client::TemplateCollection", collection: available_email_templates))

    allow_any_instance_of(Notifications::Client).to receive(:generate_template_preview) do |client, template_id, args|
      template = available_email_templates.find { |template| template.id == template_id }

      body = args[:personalisation].reduce(template.body) do |template_body, (field, value)|
        template_body.gsub("((#{field}))", value)
      end

      instance_double("Notifications::Client::TemplatePreview",
        id: template.id,
        body: body,
        subject: template.subject,
        version: 1,
        type: "email")
    end
  end
end
