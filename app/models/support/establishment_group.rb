class Support::EstablishmentGroup < ApplicationRecord
  belongs_to :establishment_group_type, class_name: "Support::EstablishmentGroupType"
  has_many :cases, class_name: "Support::Case", as: :organisation

  enum status: { proposed_to_open: 0, open: 1, closed: 2 }

  def formatted_name
    "#{uid} - #{name}"
  end
end
