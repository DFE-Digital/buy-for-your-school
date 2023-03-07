module Support
  class Cases::AttachmentsController < Cases::ApplicationController
    def index
      @case_attachments = current_case.case_attachments
      @energy_bills = current_case.energy_bills
    end
  end
end
