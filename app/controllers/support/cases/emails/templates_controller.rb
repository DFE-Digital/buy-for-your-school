module Support
  class Cases::Emails::TemplatesController < Cases::ApplicationController
    def index
      @back_url = new_support_case_email_type_path(@current_case)
    end
  end
end
