require "dry-initializer"

module Support
  # Merge a new support cases emails into an existing support case
  #
  # @see Support::ActivityLogItem

  class MergeCaseEmails
    extend Dry::Initializer

    # @!attribute from_case
    #   @return [Support::Case]
    param :from_case, ->(id) { Case.find_by(ref: id) }

    # @!attribute to_case
    #   @return [Support::Case]
    param :to_case, ->(id) { Case.find_by(ref: id) }

    # @return [Support::ActivityLogItem]
    def call
      from_case.interactions.update_all(case_id: to_case.id)
      from_case.emails.update_all(case_id: to_case.id)
      to_case.pending!
    end
  end
end
