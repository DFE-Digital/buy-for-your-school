module Support
  class ProcurementStage < ApplicationRecord
    has_many :cases, class_name: "Support::Case"

    def self.stages = Support::ProcurementStage.distinct.order(:stage).pluck(:stage)
  end
end
