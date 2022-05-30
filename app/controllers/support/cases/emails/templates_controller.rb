module Support
  class Cases::Emails::TemplatesController < Cases::ApplicationController
    def index
      @back_url =  support_case_path(@current_case)
    end
  end
end
