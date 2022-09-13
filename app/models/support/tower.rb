module Support
  class Tower < ApplicationRecord
    # Since these are all coming from other records, there is a risk of method collision
    # To avoid this, prefixes are used
    enum state: Case.states, _prefix: :case
    enum stage: Procurement.stages, _prefix: :procurement
    enum support_level: Case.support_levels, _prefix: :level

    def self.unique_procops_towers
      order(procops_tower: :asc).where.not(procops_tower: nil).pluck(:procops_tower).uniq
    end
  end
end
