require "dry-initializer"
require "types"

# Parses Liquid templates and renders them
#
class LiquidParser
  extend Dry::Initializer

  # @example
  #   {% if answer_3MpHE6gkYmmbHqzr9tUZzw %}
  #   - The cost of the service: {{answer_3MpHE6gkYmmbHqzr9tUZzw.response}}
  #   {% endif %}
  option :template, Types::Strict::String
  # @example
  #   { "answer_3MpHE6gkYmmbHqzr9tUZzw" => { "response" => "50" },
  #     "answer_1UI0NhH8gu4FKVOKBWh4pI" => { "response" => "Yes", "further_information" => nil } }
  option :answers, Types::Strict::Hash

  # Fill in answers and render specification
  #
  # @example
  #   - The cost of the service: 50
  #
  # @return [String]
  def call
    Liquid::Template.parse(template, error_mode: :strict).render(answers)
  end
end
