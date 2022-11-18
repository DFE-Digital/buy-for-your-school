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
      Tower.destroy_all if reset

      yaml = YAML.load_file(data)

      load_towers!(yaml["towers"])
      load_categories!(yaml["categories"])
    end

    def load_towers!(towers)
      towers.each do |tower|
        record = Tower.find_or_initialize_by(title: tower["title"])
        record.save!
      end
    end

    def load_categories!(categories)
      categories.each do |category|
        record = Category.top_level.find_or_initialize_by(title: category["title"])
        record.description = category["description"]
        record.slug = category["slug"]
        record.tower = Tower.find_by(title: category["tower"]) if category["tower"].present?
        record.archived = category["is_archived"] == true
        record.save!

        load_sub_categories!(category["sub_categories"], record)
      end
    end

    def load_sub_categories!(sub_categories, category)
      sub_categories.each do |sub_category|
        record = category.sub_categories.find_or_initialize_by(title: sub_category["title"])
        record.description = sub_category["description"]
        record.slug = sub_category["slug"]
        record.tower = (Tower.find_by(title: sub_category["tower"]) if sub_category["tower"].present?) || category.tower
        record.archived = sub_category["is_archived"] == true
        record.save!
      end
    end
  end
end
