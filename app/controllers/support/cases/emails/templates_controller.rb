module Support
  class Cases::Emails::TemplatesController < Cases::ApplicationController
    def index
      @back_url = new_support_case_email_type_path(@current_case)
      @email_templates = Notifications::Client.new(ENV["NOTIFY_API_KEY"])
        .get_all_templates(type: "email")
        .collection
    end
  end
end
