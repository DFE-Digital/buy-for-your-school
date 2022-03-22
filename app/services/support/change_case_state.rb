require "dry-initializer"
require "types"

module Support
  #
  # Creates an interaction record (for case history) when changing the state of case
  #
  class ChangeCaseState
    extend Dry::Initializer

    option :kase, ::Types.Instance(Case), optional: false
    option :agent, ->(value) { value.is_a?(Agent) ? AgentPresenter.new(value) : value }, optional: false
    option :to, ::Types::Symbol, optional: false

    #  reason:
    #   a closure reason can be supplied and is applied if the new state is "closed"
    #
    #  info:
    #   additional information can be supplied and is appended to the end of :body
    #
    #  body:
    #   can be overwritten completely but will by default have the format:
    #   'From resolved to closed by Agent Smith on 11 Mar 15:15<info>'
    #
    option :reason, ::Types::Symbol | ::Types::String, optional: true
    option :info, ::Types::String, optional: true
    option :body, ::Types::String, default: proc { "From #{from} to #{to_message} by #{agent.full_name} on #{date}#{info}" }

    def call
      kase.interactions.state_change.build(
        body: body,
        agent_id: agent.id,
      )

      kase.closure_reason = reason if to == :close

      kase.send("#{to}!")
    end

  private

    def from
      @from ||= I18n.t("support.case.label.state.state_#{kase.state}").downcase
    end

    def to_message
      @to_message ||= I18n.t("support.case.label.state.state_#{to}").downcase
    end

    def date
      @date ||= Time.zone.now.to_formatted_s(:short)
    end
  end
end
