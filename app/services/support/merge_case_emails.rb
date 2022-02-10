require "dry-initializer"

module Support
  #
  # Merge a new support cases emails into an existing support case
  #
  class MergeCaseEmails
    class CaseNotNewError < StandardError; end

    extend Dry::Initializer

    # @!attribute from_case
    #   @return [Support::Case]
    option :from_case

    # @!attribute to_case
    #   @return [Support::Case]
    option :to_case

    # @return [Support::CasePresenter, Support::CasePresenter]
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
