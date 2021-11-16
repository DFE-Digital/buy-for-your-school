module Support
  class CaseCategorisationForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] category_id
    # @return [String, nil]
    option :category_id, Types::Params::String | Types::Params::Nil, optional: true
  end
end
