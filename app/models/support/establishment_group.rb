class Support::EstablishmentGroup < ApplicationRecord
  belongs_to :establishment_group_type, class_name: "Support::EstablishmentGroupType"
  has_many :cases, class_name: "Support::Case", as: :organisation

  enum status: { proposed_to_open: 0, open: 1, closed: 2, proposed_to_close: 3 }

  def self.find_by_gias_id(uid)= find_by(uid:)

  def formatted_name
    "#{uid} - #{name}"
  end

  def gias_id = uid
end
