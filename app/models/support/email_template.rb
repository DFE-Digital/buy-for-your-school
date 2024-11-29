module Support
  class EmailTemplate < ApplicationRecord
    include Support::Concerns::ScopeActive

    STAGE_VALUES = [0, 1, 2, 3, 4].freeze

    belongs_to :group, class_name: "Support::EmailTemplateGroup", foreign_key: "template_group_id"
    belongs_to :created_by, class_name: "Support::Agent"
    belongs_to :updated_by, class_name: "Support::Agent", optional: true
    has_many :emails, class_name: "Support::Email", foreign_key: "template_id"
    has_many :attachments, class_name: "Support::EmailTemplateAttachment", foreign_key: "template_id", dependent: :destroy

    validates :stage, inclusion: { in: STAGE_VALUES }, allow_nil: true

    default_scope { order(:title) }

    scope :by_groups, ->(template_group_ids) { where(template_group_id: template_group_ids) }
    scope :by_stages, ->(stages, include_null: false) { include_null ? where(stage: stages).or(where(stage: nil)) : where(stage: stages) }
    scope :without_stage, -> { where(stage: nil) }

    def self.stages = STAGE_VALUES

    def archive!(agent = nil)
      updates = {
        archived: true,
        archived_at: Time.zone.now,
      }
      updates[:updated_by] = agent if agent.present?
      update!(updates)
    end
  end
end
