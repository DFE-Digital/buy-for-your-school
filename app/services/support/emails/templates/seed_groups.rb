require "yaml"

module Support
  module Emails
    module Templates
      class SeedGroups
        def initialize(data: "./config/support/email_template_groups.yml")
          @data = data
        end

        def call
          yaml = YAML.load_file(@data)
          load_groups!(yaml["groups"])
        end

        def load_groups!(groups)
          groups.each do |group|
            record = Support::EmailTemplateGroup.top_level.find_or_initialize_by(title: group["title"])
            record.archived = group["is_archived"] == true
            record.save!

            load_sub_groups!(group["sub_groups"], record)
          end
        end

        def load_sub_groups!(sub_groups, group)
          sub_groups.each do |sub_group|
            record = group.sub_groups.find_or_initialize_by(title: sub_group["title"])
            record.archived = sub_group["is_archived"] == true
            record.save!
          end
        end
      end
    end
  end
end
