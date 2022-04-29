module Support
  class Messages::Send
    extend Dry::Initializer

    include MarkdownHelper

    option :body, Types::String, optional: false
    option :kase, Types.Instance(Support::Case), optional: false
    option :agent, Types.Instance(Support::AgentPresenter), optional: false

    def call
      # create an email
      # add a signature
      # create the interaction
      # send the email
      render = Liquid::Template.parse(basic_template, error_mode: :strict).render(basic_template_variables)
      email_body = markdown_to_html(render)

      email = Support::Email.new(body: email_body, case: kase, sent_at: Time.zone.now, sender: { name: agent.full_name, address: nil })
      email.save!
      email.create_interaction
    end

    def basic_template
      "{{body}}\n\n"\
      "Regards<br>"\
      "{{agent}}<br>"\
      "Procurement Specialist<br>"\
      "Get help buying for schools"
    end

    def basic_template_variables
      {
        "body" => body,
        "agent" => agent.full_name,
      }
    end
  end
end
