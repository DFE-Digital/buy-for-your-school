module Frameworks::Evaluation::Presentable
  extend ActiveSupport::Concern

  def framework_name
    framework.try(:name)
  end

  def framework_reference_and_name
    framework.try(:reference_and_name)
  end

  def framework_provider_name
    framework.try(:provider_name)
  end

  def framework_category_names
    framework.try(:category_names)
  end

  def display_status
    ApplicationController.render(partial: "frameworks/evaluations/status", locals: { status: })
  end

  def display_assignee
    assignee.try(:full_name)
  end

  def display_last_updated
    updated_at.strftime("%d %B %Y at %H:%M:%S")
  end

  def contact_name
    contact.try(:name)
  end

  def contact_email
    contact.try(:email)
  end

  def contact_phone
    contact.try(:phone)
  end
end
