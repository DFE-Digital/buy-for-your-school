module Support
  class CaseMergeEmailsForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] merge_to_case_id
    # @return [String, nil]
    option :merge_into_case_id, Types::Params::String, optional: true
  end
end
