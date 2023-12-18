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

  def contract_start_date_formatted
    return if contract_start_date.nil?

    contract_start_date.strftime(I18n.t("date.formats.presenter"))
  end

  def same_supplier_used_formatted
    return if same_supplier_used.nil?

    I18n.t("faf.same_supplier.options.#{same_supplier_used}")
  end

  def flow = nil

  def origin = nil
end
