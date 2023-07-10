require "dry-initializer"

module Support
  #
  # Merge a new support cases emails into an existing support case
  #
  # TODO:
  #   1. If adding any further merging functionality to this class, consider adding a merged_into_case_id
  #      to t.support_cases to keep a record of the case a case was merged into.
  #
  #   2. The inverse should also be applied to t.support_emails and t.support_interactions to keep a record of their
  #      original case (e.g. original_case_id).
  #
  class MergeCaseEmails
    extend Dry::Initializer

    # @!attribute from_case
    #   @return [Support::Case]
    option :from_case, Types.Instance(Support::Case), optional: false

    # @!attribute to_case
    #   @return [Support::Case]
    option :to_case, Types.Instance(Support::Case), optional: false

    # @!attribute agent
    #   @return [Support::Agent]
    option :agent, Types.Instance(Support::AgentPresenter), optional: false

    # @return [TrueClass]
    def call
      from!
      to!
    end

  private

    def from!
      from_case.transaction do
        # move emails and interactions over to the to_case
        from_case.interactions&.update_all(case_id: to_case.id)
        from_case.emails&.update_all(case_id: to_case.id)

        # create a email_merge interaction record
        from_case.interactions.email_merge.build(
          body: "to ##{to_case.ref}",
          agent_id: agent.id,
        )
        from_case.update!(action_required: false)

        # update the case status and create a state_change interaction record
        ChangeCaseState.new(
          kase: from_case,
          agent:,
          to: :close,
          reason: :email_merge,
          info: ". Email(s) moved to case ##{to_case.ref}",
        ).call
      end
    end

    def to!
      to_case.transaction do
        to_case.interactions.email_merge.build(
          body: "from ##{from_case.ref}",
          agent_id: agent.id,
        )
        to_case.update!(action_required: true)
      end
    end
  end
end
