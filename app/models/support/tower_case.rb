module Support
  class TowerCase < ApplicationRecord
    UNSPECIFIED_VALUE = 99
    enum state: Case.states, _prefix: :state
    enum stage: Procurement.stages.merge(unspecified: UNSPECIFIED_VALUE), _prefix: :stage
    enum support_level: Case.support_levels.merge(unspecified: UNSPECIFIED_VALUE), _prefix: :support_level
    belongs_to :support_tower, class_name: "Support::Tower", foreign_key: :tower_id
  end
end
