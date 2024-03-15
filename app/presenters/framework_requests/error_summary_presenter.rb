class FrameworkRequests::ErrorSummaryPresenter
  include Rails.application.routes.url_helpers

  def initialize(error_messages, framework_request_id, user)
    @error_messages = error_messages
    @framework_request_id = framework_request_id
    @user = user
  end

  def formatted_error_messages
    @error_messages.map { |attribute, messages| [attribute, messages.first, map_attribute_to_link(attribute)] }
  end

private

  def map_attribute_to_link(attribute)
    case attribute
    when :first_name, :last_name then edit_framework_request_name_path(id: @framework_request_id)
    when :email then edit_framework_request_email_path(id: @framework_request_id)
    when :org_id then @user.guest? ? edit_framework_request_search_for_organisation_path(id: @framework_request_id) : edit_framework_request_select_organisation_path(id: @framework_request_id)
    when :category then edit_framework_request_category_path(id: @framework_request_id)
    when :procurement_amount then edit_framework_request_procurement_amount_path(id: @framework_request_id)
    when :message_body then edit_framework_request_message_path(id: @framework_request_id)
    when :origin then edit_framework_request_origin_path(id: @framework_request_id)
    else "#"
    end
  end
end
