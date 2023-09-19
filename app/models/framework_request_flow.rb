class FrameworkRequestFlow
  delegate :contract_length, to: :@framework_request
  delegate :contract_start_date_known, to: :@framework_request
  delegate :same_supplier_used, to: :@framework_request
  delegate :multischool_with_multiple_selections?, to: :@framework_request
  delegate :energy_category?, to: :@framework_request
  delegate :have_energy_bill, to: :@framework_request
  delegate :document_types, to: :@framework_request

  def initialize(framework_request)
    @framework_request = framework_request
  end

  def unfinished?
    return false if get_flow.nil?

    if services? || energy?
      return true if contract_length.nil? || contract_start_date_known.nil? || (multischool_with_multiple_selections? && same_supplier_used.nil?)
    end

    if services? && document_types.empty?
      return true
    end

    if energy? && energy_category? && have_energy_bill.nil?
      return true
    end

    false
  end

  def services? = get_flow == "services"

  def energy? = get_flow == "energy"

  def goods? = get_flow == "goods"

  def not_fully_supported? = get_flow == "not_fully_supported"

  def energy_or_services? = energy? || services?

private

  def get_flow
    return if @framework_request.category.nil?

    @framework_request.category.flow
  end
end
