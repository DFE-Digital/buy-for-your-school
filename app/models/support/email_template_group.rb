module Support
  class EmailTemplateGroup < ApplicationRecord
    belongs_to :parent, class_name: "Support::EmailTemplateGroup", optional: true
    has_many :templates, class_name: "Support::EmailTemplate", foreign_key: "template_group_id"
    has_many :sub_groups, class_name: "Support::EmailTemplateGroup", foreign_key: "parent_id"

    scope :top_level, -> { where(parent_id: nil) }

    def hierarchy
      return [self] unless parent

      parent.hierarchy + [self]
    end

    def is_top_level? = parent_id.blank?
  end
end
