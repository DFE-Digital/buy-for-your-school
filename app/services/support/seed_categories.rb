require "yaml"
require "dry-initializer"
require "types"

# make task that goes through support categories and renames No applicable category to Other
# put this in seed categories and run first so it won't add a new one

module Support
  #
  # Persist (Sub)Categories from YAML file
  #
  # @example
  #   SeedCategories.new(data: "/path/to/file.yml").call
  #
  class SeedCategories
    extend Dry::Initializer

    # @!attribute [r] data
    # @return [String] (defaults to ./config/support/categories.yml)
    option :data, Types::String, default: proc { "./config/support/categories.yml" }
    # @!attribute [r] reset
    # @return [Boolean] (defaults to false)
    option :reset, Types::Bool, default: proc { false }

    # @return [Array<Hash>]
    #
    def call
      Category.destroy_all if reset

      YAML.load_file(data).each do |group|
        category = Support::Category.top_level.find_or_create_by!(title: group["title"]) do |cat|
          cat.description = group["description"]
          cat.slug = group["slug"]
        end

        group["sub_categories"].each do |sub_group|
          category.sub_categories.find_or_create_by!(title: sub_group["title"]) do |cat|
            cat.description = sub_group["description"]
            cat.slug = sub_group["slug"]
          end
        end
      end
    end
  end
end
