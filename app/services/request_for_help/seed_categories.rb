require "yaml"

module RequestForHelp
  class SeedCategories
    def initialize(data: "./config/request_for_help/categories.yml")
      @data = data
    end

    def call
      yaml = YAML.load_file(@data, aliases: true)
      load_categories!(yaml["categories"])
    end

    def load_categories!(categories)
      categories.each do |category|
        record = RequestForHelpCategory.top_level.find_or_initialize_by(title: category["title"])
        record.description = category["description"]
        record.slug = category["slug"]
        record.archived = category["is_archived"] == true
        record.support_category = Support::Category.active.find_by(title: category["support_category"])
        record.save!

        load_sub_categories!(category["sub_categories"], record)
      end
    end

    def load_sub_categories!(sub_categories, category)
      sub_categories&.each do |sub_category|
        record = category.sub_categories.find_or_initialize_by(title: sub_category["title"])
        record.description = sub_category["description"]
        record.slug = sub_category["slug"]
        record.archived = sub_category["is_archived"] == true
        record.support_category = Support::Category.active.find_by(title: sub_category["support_category"])
        record.save!

        load_sub_categories!(sub_category["sub_categories"], record)
      end
    end
  end
end
