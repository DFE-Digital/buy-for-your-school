# frozen_string_literal: true

module Support
  class CaseSearchForm < CaseFilterForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] search_term
    # @return [String]
    option :search_term, Types::Params::String, optional: true
  end
end
