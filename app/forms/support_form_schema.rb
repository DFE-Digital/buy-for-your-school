require "dry/validation"

Dry::Validation.load_extensions(:predicates_as_macros)

#
# Validate "support request" form details from a "school business professional"
#
# If a specification is not selected, the user must choose a category
#
# @author Peter Hamilton
#
class SupportFormSchema < Dry::Validation::Contract
  import_predicates_as_macros

  config.messages.backend = :i18n
  config.messages.top_namespace = :forms
  config.messages.load_paths << Rails.root.join("config/locales/validation/en.yml")

  params do
    optional(:phone_number).value(:string)  # step 1
    optional(:journey_id).value(:string)    # step 2
    optional(:category_id).value(:string)   # step 3
    optional(:message_body).value(:string)  # step 4
  end

  # rule(:phone_number).validate(min_size?: 10, max_size?: 11, format?: /^0\d+$/)
  # rule(:phone_number).validate(max_size?: 11, format?: /(^$|^0\d+$)/)
  rule(:phone_number).validate(max_size?: 11, format?: /(^$|^0\d{10,}$)/)

  rule(:journey_id, :category_id) do
    key(:category_id).failure(:no_spec) if key?(:category_id) && values[:category_id].blank? && values[:journey_id].eql?("none")
  end

  rule(:message_body) do
    key.failure(:missing) if key? && value.blank?
  end
end
