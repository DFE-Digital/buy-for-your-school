RSpec.shared_context "with notify email templates" do
  let(:available_email_templates) do
    [
      instance_double("Notifications::Client::Template", id: "f4696e59-8d89-4ac5-84ca-17293b79c337",
                                                         name: "what_is_a_framework",
                                                         body: "Hi ((toName)), here is information regarding frameworks",
                                                         subject: "Email subject 1"),

      instance_double("Notifications::Client::Template", id: "6c76ed8c-030e-4c69-8f25-ea0c66091bc5",
                                                         name: "approaching_suppliers",
                                                         body: "Hi ((toName)), here is information regarding approaching suppliers",
                                                         subject: "Email subject 2"),

      instance_double("Notifications::Client::Template", id: "12430165-4ae7-47aa-baa3-d0b3c5440a9b",
                                                         name: "catering_frameworks",
                                                         body: "Hi ((toName)), here is information regarding catering frameworks",
                                                         subject: "Email subject 3"),

      instance_double("Notifications::Client::Template", id: "bb4e6925-3491-44b8-8747-bdbb31257403",
                                                         name: "social_value",
                                                         body: "Hi ((toName)), here is information regarding social value",
                                                         subject: "Email subject 4"),

      instance_double("Notifications::Client::Template", id: "ac679471-8bb9-4364-a534-e87f585c46f3",
                                                         name: "basic",
                                                         body: "Hi ((toName)), here is a basic template",
                                                         subject: "Email subject 5"),

    ]
  end

  before do
    allow_any_instance_of(Notifications::Client).to receive(:get_all_templates)
      .with(include(type: "email"))
      .and_return(instance_double("Notifications::Client::TemplateCollection", collection: available_email_templates))

    allow_any_instance_of(Notifications::Client).to receive(:generate_template_preview) do |_client, template_id, args|
      template_to_preview = available_email_templates.find { |template| template.id == template_id }

      body = args[:personalisation].reduce(template_to_preview.body) do |template_body, (field, value)|
        template_body.gsub("((#{field}))", value)
      end

      instance_double("Notifications::Client::TemplatePreview",
                      id: template_to_preview.id,
                      body: body,
                      subject: template_to_preview.subject,
                      version: 1,
                      type: "email")
    end
  end
end
