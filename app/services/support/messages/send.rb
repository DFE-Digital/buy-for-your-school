module Support
  class Messages::Send
    extend Dry::Initializer

    option :body, Types::String, optional: false
    option :kase, Types.Instance(Support::Case), optional: false
    option :agent, Types.Instance(Support::AgentPresenter), optional: false

    def call
      # create an email
      # add a signature
      # create the interaction
      # send the email
      email_body = Messages::Templates.new(params: { body: body, agent: agent.full_name }).call
      email = Support::Email.new(body: email_body, case: kase, sent_at: Time.zone.now, sender: { name: agent.full_name, address: nil })
      email.save!

      ::Support::Messages::Outlook::SurfaceEmailOnCase.call(email)
    end
  end
end
