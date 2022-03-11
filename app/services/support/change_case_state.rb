module Support
  #
  # Creates an interaction record (for case history) when changing the state of case
  #
  # The interaction will be given a body message in the format:
  # default: "From resolved to closed by Agent Smith on 11 Mar 15:15"
  #
  # A closure reason can also be supplied and is required when the new state is "closed"
  #
  class ChangeCaseState
    extend Dry::Initializer

    option :kase,    Types.Instance(Case) | Types.Instance(CasePresenter), optional: false
    option :agent,   Types.Instance(Agent) | Types.Instance(AgentPresenter), optional: false
    option :to,      Types::Symbol, optional: false

    option :reason,  Types::Symbol, optional: proc { to != :closed }
    option :before,  Types::String, optional: true
    option :after,   Types::String, optional: true
    option :from,    Types::String, default: proc { I18n.t("support.case.label.state.state_#{kase.state}").downcase }
    option :date,    Types::String, default: proc { Time.zone.now.to_formatted_s(:short) }
    option :body,    Types::String, default: proc { "#{before}From #{from} to #{to} by #{agent.full_name} on #{date}#{after}" }

    def call
      kase.interactions.state_change.build(
        body: body,
        agent_id: agent.id,
      )

      kase.update!(
        state: to,
        closure_reason: (reason if to == :closed),
      )
    end
  end
end
