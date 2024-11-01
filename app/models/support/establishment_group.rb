class Support::EstablishmentGroup < ApplicationRecord
  belongs_to :establishment_group_type, class_name: "Support::EstablishmentGroupType"
  has_many :cases, class_name: "Support::Case", as: :organisation

  enum :status, { proposed_to_open: 0, open: 1, closed: 2, proposed_to_close: 3 }

  delegate :federation?, to: :establishment_group_type
  delegate :sat?, to: :establishment_group_type

  def formatted_name
    "#{uid} - #{name}"
  end

  def postcode
    address["postcode"]
  end

  def organisations
    return Support::Organisation.where(federation_code: uid) if federation?

    Support::Organisation.where(trust_code: uid)
  end

  def org_type
    establishment_group_type&.name
  end

  def mat_or_trust? = establishment_group_type.mat? || establishment_group_type.trust?

  def eligible_for_school_picker?
    (mat_or_trust? || federation?) && organisations.count > 1
  end

  def organisations_for_multi_school_picker
    organisations
  end
end
