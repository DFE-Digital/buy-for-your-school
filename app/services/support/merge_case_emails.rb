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
    class CaseNotNewError < StandardError; end

    extend Dry::Initializer

    # @!attribute from_case
    #   @return [Support::Case]
    option :from_case, Types.Instance(Support::Case), optional: false

    # @!attribute to_case
    #   @return [Support::Case]
    option :to_case, Types.Instance(Support::Case), optional: false

    # @return [TrueClass]
    def call
      from_case.transaction do
        raise CaseNotNewError unless from_case.initial?

        from_case.interactions&.update_all(case_id: to_case.id)
        from_case.emails&.update_all(case_id: to_case.id)
        from_case.closed!
      end
      to_case.pending!
    end
  end
end
