class Frameworks::Framework::SpreadsheetImportable::RowMapping
  attr_reader :row

  def initialize(row)
    @row = row
  end

  def valid?
    # If number column has a value, to prevent empty rows being imported
    row[nil].present?
  end

  def provider = Frameworks::Provider.find_or_create_by!(short_name: row["FWK Provider"])

  def provider_reference = row["Framework Reference "]

  def attributes
    {
      provider:,
      provider_contact:,
      status:,
      name:,
      url:,
      provider_reference:,
      faf_added_date:,
      faf_end_date:,
      sct_framework_provider_lead:,
      sct_framework_owner:,
      proc_ops_lead:,
      e_and_o_lead:,
    }
  end

private

  def name = row["Framework Name"]

  def provider_contact
    name  = String(row["PBO Framework Owner"]) == "-" ? "" : String(row["PBO Framework Owner"])
    email = String(row["PBO Framework Email"]) == "-" ? "" : String(row["PBO Framework Email"])

    return nil if email.blank?

    if name.blank? && email.present?
      Frameworks::ProviderContact.create_with(name: email).find_or_create_by!(provider:, email:)
    elsif name.present? && email.present?
      Frameworks::ProviderContact.create_with(name:).find_or_create_by!(provider:, email:)
    end
  end

  def status
    recommended = String(row["Presently Recommended Y/N"]).downcase.inquiry

    if recommended.y?
      :dfe_approved
    elsif recommended.n?
      :not_approved
    end
  end

  def url = (row["Framework Name"].url if row["Framework Name"].respond_to?(:url))

  def faf_added_date = row["Date when added on FaF"]

  def faf_end_date = row["Contracted End Date on FaF as at 20.1.2023"]

  def sct_framework_provider_lead = row["Current PSBO Lead (Interim - To Be Confirmed)"]

  def sct_framework_owner = row["SCT Framework Owner"]

  def proc_ops_lead = Support::Agent.find_or_create_by_full_name(row["Proc Ops Lead"])

  def e_and_o_lead = Support::Agent.find_or_create_by_full_name(row["Engagement and Outreach Lead"])
end
