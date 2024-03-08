module Support
  class ProcurementStage < ApplicationRecord
    has_many :cases, class_name: "Support::Case"

    scope :substages_for_stage, ->(stage) { where(stage:).by_lifecycle_order }
    scope :by_lifecycle_order, -> { order(lifecycle_order: :asc) }

    def self.stages = Support::ProcurementStage.distinct.order(:stage).pluck(:stage)
  end
end
