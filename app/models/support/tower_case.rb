module Support
  class TowerCase < ApplicationRecord
    UNSPECIFIED_VALUE = 99
    enum :state, Case.states, prefix: :state
    enum :support_level, Case.support_levels.merge(unspecified: UNSPECIFIED_VALUE), prefix: :support_level
    belongs_to :support_tower, class_name: "Support::Tower", foreign_key: :tower_id
    belongs_to :procurement_stage, class_name: "Support::ProcurementStage"
    belongs_to :procurement, class_name: "Support::Procurement"
  end
end
