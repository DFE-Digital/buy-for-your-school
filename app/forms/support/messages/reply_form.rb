module Support
  class Messages::ReplyForm < Form
    extend Dry::Initializer
    include Concerns::ValidatableForm

    # @!attribute [r] body
    # @return [String]
    option :body, Types::Params::String, optional: true
  end
end
