require "yaml"
require "dry-initializer"
require "types"

module Support
  #
  # Persist (Sub)Categories from YAML file
  #
  # @example
  #   SeedCategories.new(data: "/path/to/file.yml").call
  #
  class SeedCategories
    extend Dry::Initializer

    option :data, Types::String, default: proc { "./config/support/categories.yml" }
    option :reset, Types::Bool, default: proc { false }

    # @return [Array<Hash>]
    #
    def call
      Category.destroy_all if reset

      YAML.load_file(data).each do |group|
        category = Category.find_or_create_by!(title: group["title"]) do |cat|
          cat.description = group["description"]
          cat.slug = group["slug"]
        end

        group["sub_categories"].each do |sub_group|
          SubCategory.find_or_create_by!(title: sub_group["title"]) do |cat|
            cat.description = sub_group["description"]
            cat.slug = sub_group["slug"]
            cat.category_id = category.id
          end
        end
      end
    end
  end
end
