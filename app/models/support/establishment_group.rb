# :nocov:
class Support::EstablishmentGroup < ApplicationRecord
  belongs_to :establishment_group_type, class_name: "Support::EstablishmentGroupType"

  enum status: { proposed_to_open: 0, open: 1, closed: 2 }

  def formatted_name
    "#{uid} - #{name}"
  end
end
# :nocov:
