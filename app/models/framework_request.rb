class FrameworkRequest < Request
  DOCUMENT_TYPES = %w[current_contract communications_with_supplier floor_plans quotes specifications other none].freeze

  belongs_to :user, optional: true
  belongs_to :category, class_name: "RequestForHelpCategory", optional: true
  belongs_to :support_case, class_name: "Support::Case", optional: true

  has_many :energy_bills, class_name: "EnergyBill"
  has_many :documents, class_name: "Document"

  before_save :clear_school_urns, if: -> { attribute_changed?(:org_id) }
  before_save :clear_same_supplier_used, if: -> { attribute_changed?(:org_id) }
  before_save :clear_attributes_by_flow, if: -> { attribute_changed?(:category_id) }
  before_save :auto_assign_sat_school, if: -> { sat_selected? }

  enum energy_request_about: { energy_contract: 1, not_energy_contract: 0 }, _suffix: true
  enum energy_alternative: { different_format: 0, email_later: 1, no_bill: 2, no_thanks: 3 }, _suffix: true
  enum :contract_length, { not_sure: 0, one_year: 1, two_years: 2, three_years: 3, four_years: 4, five_years: 5 }, prefix: true
  enum :same_supplier_used, { no: 0, yes: 1, not_sure: 2 }, prefix: true
  enum :origin, { used_before: 0, meeting_or_event: 1, dfe_publication: 2, non_dfe_publication: 3, recommendation: 4, search_engine: 5, social_media: 6, website: 7, other: 8 }, prefix: true

  validates :document_types, inclusion: { in: DOCUMENT_TYPES }, allow_nil: true

  def self.document_types = DOCUMENT_TYPES

  def has_bills?
    energy_bills.any?
  end

  def has_documents?
    documents.any?
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

  def multischool_with_multiple_selections?
    multischool? && school_urns.size > 1
  end

  def submit_documents
    documents.each(&:submit)
  end

  def energy_category?
    category.gas? || category.electricity?
  end

  def flow
    FrameworkRequestFlow.new(self)
  end

  def is_energy_or_services?
    flow&.energy_or_services? || category.is_energy_or_services?
  end

private

  def sat_selected?
    attribute_changed?(:org_id) && group && organisation&.sat?
  end

  def auto_assign_sat_school
    return if organisation.organisations.empty?

    self.school_urns = [organisation.organisations.first.urn]
  end

  def clear_school_urns
    self.school_urns = []
  end

  def clear_same_supplier_used
    self.same_supplier_used = nil
  end

  def clear_attributes_by_flow
    if flow.goods? || flow.not_fully_supported?
      self.contract_length = nil
      self.contract_start_date_known = nil
      self.contract_start_date = nil
      self.same_supplier_used = nil
      self.document_types = []
      self.document_type_other = nil
      energy_bills.destroy_all
      documents.destroy_all
    elsif flow.energy?
      self.document_types = []
      self.document_type_other = nil
      documents.destroy_all
    elsif flow.services?
      self.have_energy_bill = nil
      self.energy_alternative = nil
      energy_bills.destroy_all
    end
  end
end
