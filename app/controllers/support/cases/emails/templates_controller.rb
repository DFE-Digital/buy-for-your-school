module Support
  class Cases::Emails::TemplatesController < Cases::ApplicationController
    def index
      @back_url = new_support_case_email_type_path(@current_case)
      @email_templates = acceptable_email_templates
    end

  private

    def acceptable_email_templates
      templates_to_ignore = %w[auto-reply blank default]

      Notifications::Client.new(ENV["NOTIFY_API_KEY"])
        .get_all_templates(type: "email")
        .collection
        .reject { |template| template.name.downcase.in?(templates_to_ignore) }
    end
  end
end
