module Frameworks::Framework::Presentable
  extend ActiveSupport::Concern

  def provider_name
    provider.name || provider.short_name
  end

  def reference_and_short_name
    [reference, short_name].compact.join(" - ")
  end

  def provider_framework_owner_phone
    provider_contact&.phone
  end

  def provider_framework_owner_name
    provider_contact&.name
  end

  def provider_framework_owner_email
    provider_contact&.email
  end

  def category_name
    support_category&.title
  end

  def proc_ops_lead_name
    proc_ops_lead&.full_name
  end

  def e_and_o_lead_name
    e_and_o_lead&.full_name
  end

  def display_status
    ApplicationController.render(partial: "frameworks/frameworks/framework_status", locals: { status: })
  end

  def display_dfe_start_date
    dfe_start_date.strftime("%d/%m/%Y") if dfe_start_date.present?
  end

  def display_dfe_end_date
    dfe_end_date.strftime("%d/%m/%Y") if dfe_end_date.present?
  end

  def display_provider_start_date
    provider_start_date.strftime("%d/%m/%Y") if provider_start_date.present?
  end

  def display_provider_end_date
    provider_end_date.strftime("%d/%m/%Y") if provider_end_date.present?
  end
end
