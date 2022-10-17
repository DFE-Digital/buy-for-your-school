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
        category = Support::Category.top_level.find_or_initialize_by(title: group["title"])
        category.description = group["description"]
        category.slug = group["slug"]
        category.tower = Support::Tower.find_or_initialize_by(title: group["tower"]) if group["tower"].present?
        category.save!

        group["sub_categories"].each do |sub_group|
          sub_category = category.sub_categories.find_or_initialize_by(title: sub_group["title"])
          sub_category.description = sub_group["description"]
          sub_category.slug = sub_group["slug"]
          tower = sub_group["tower"] || group["tower"]
          sub_category.tower = Support::Tower.find_or_initialize_by(title: sub_group["tower"] || group["tower"]) if tower.present?
          sub_category.save!
        end
      end
    end
  end
end
