module Support
  class CaseMergeEmailsForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] merge_into_case_ref
    # @return [String, nil]
    option :merge_into_case_ref, Types::Params::String, optional: true
    # @!attribute [r] merge_from_case_ref
    # @return [String, nil]
    option :merge_from_case_ref, Types::Params::String, optional: true
  end
end
