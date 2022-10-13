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

    def call
      Category.destroy_all if reset

      YAML.load_file(data).each do |group|
        category = Support::Category.top_level.find_or_create_by!(title: group["title"]) do |cat|
          cat.description = group["description"]
          cat.slug = group["slug"]
        end

        group["sub_categories"].each do |sub_group|
          sub_category = category.sub_categories.find_or_initialize_by(title: sub_group["title"])
          sub_category.description = sub_group["description"]
          sub_category.slug = sub_group["slug"]

          tower = sub_group["tower"] || group["tower"]

          sub_category.tower = if tower.present?
            Support::Tower.find_or_initialize_by(title: sub_group["tower"] || group["tower"])
          else
            nil
          end

          sub_category.save!
        end
      end
    end
  end
end
