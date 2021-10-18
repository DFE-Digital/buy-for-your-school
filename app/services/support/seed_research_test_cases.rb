# :nocov:
require "yaml"
require "dry-initializer"
require "types"

module Support
  #
  # Persist (Test)Cases from YAML file
  #
  # @example
  #   SeedResearchTestCases.new(data: "/path/to/file.yml").call
  #
  class SeedResearchTestCases
    extend Dry::Initializer

    option :data, Types::String, default: proc { "./config/support/research_test_cases.yml" }
    option :reset, Types::Bool, default: proc { false }

    # @return [Array<Hash>]
    #
    def call
      Case.destroy_all if reset

      YAML.load_file(data).each do |kase|
        category = Category.find_by!(title: kase["category"])

        enq = Enquiry.create!(
          name: kase["contact_name"],
          email: kase["contact_email"],
          telephone: kase["contact_phone"],
          message: kase["description"],
          category: category.title,
        )
        CreateCase.new(enq).call
      end
    end
  end
end
# :nocov:
