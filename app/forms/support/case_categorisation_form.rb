module Support
  class CaseCategorisationForm
    extend Dry::Initializer
    include Concerns::ValidatableForm

    option :category_id, Types::Params::String | Types::Params::Nil, optional: true
  end
end
