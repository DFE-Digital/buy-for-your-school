class FrameworkRequest < Request
  belongs_to :user, optional: true
  belongs_to :category, class_name: "RequestForHelpCategory", optional: true
  belongs_to :support_case, class_name: "Support::Case", optional: true

  has_many :energy_bills, class_name: "EnergyBill"

  before_save :clear_school_urns, if: -> { attribute_changed?(:org_id) }
  before_save :auto_assign_sat_school, if: -> { sat_selected? }

  enum energy_request_about: { energy_contract: 1, not_energy_contract: 0 }, _suffix: true
  enum energy_alternative: { different_format: 0, email_later: 1, no_bill: 2, no_thanks: 3 }, _suffix: true

  def allow_bill_upload?
    Flipper.enabled?(:energy_bill_flow) && is_energy_request && energy_request_about == "energy_contract" &&
      (have_energy_bill || energy_alternative == "different_format")
  end

  def has_bills?
    energy_bills.any?
  end

  def organisation
    return Support::EstablishmentGroup.find_by(uid: org_id) if group

    Support::Organisation.find_by(urn: org_id)
  end

  def selected_schools
    school_urns.map { |urn| Support::Organisation.find_by(urn:) }
  end

  def available_schools
    return Support::Organisation.none unless group

    organisation.organisations.order(:name)
  end

  def multischool?
    school_urns.present?
  end

  def clear_school_urns
    self.school_urns = []
  end

private

  def sat_selected?
    attribute_changed?(:org_id) && group && organisation.sat?
  end

  def auto_assign_sat_school
    return if organisation.organisations.empty?

    self.school_urns = [organisation.organisations.first.urn]
  end
end
