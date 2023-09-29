module CaseRequest::Presentable
  extend ActiveSupport::Concern

  def full_name
    "#{first_name} #{last_name}"
  end

  def request_type
    return nil unless category.present? || query.present?

    category.present?
  end

  def type
    request_type ? I18n.t("support.case_hub_migration.label.procurement") : I18n.t("support.case_hub_migration.label.non_procurement")
  end

  def contract_length = nil

  def flow = nil

  def same_supplier_used = nil

  def origin = nil
end
