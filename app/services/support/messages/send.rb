module Support
  class Messages::Send
    extend Dry::Initializer

    include MarkdownHelper

    option :body, Types::String, optional: false
    option :kase, Types.Instance(Support::Case), optional: false
    option :agent, optional: false, default: proc { |value| Support::AgentPresenter.new(value) }

    def call
      # create an email
      # add a signature
      # create the interaction
      # send the email
      template = "{{text}}\n\n"\
                  ""\
                  "Regards\n"\
                  "{{agent}}\n"\
                  "Procurement Specialist\n"\
                  "Get help buying for schools"
        
      render = Liquid::Template.parse(template, error_mode: :strict).render("text" => body, "agent" => agent.full_name)
      email_body = markdown_to_html(render)

      email = Support::Email.new(body: email_body, case: kase, sent_at: DateTime.now)
      email.save
      email.create_interaction
    end  
  end
end    