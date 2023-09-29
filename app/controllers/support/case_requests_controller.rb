module Support
  class CaseRequestsController < ApplicationController
    before_action -> { @back_url = support_cases_path }, only: %i[new create]

    def new
      @case_request = CaseRequest.new
    end

    def create
      @case_request = CaseRequest.new(form_params.except(:upload_reference))
      @case_request.created_by = current_agent

      if @case_request.valid?
        @case_request.save!
        # kase = @case_request.create_case

        # create_interaction(kase.id, "create_case", "Case created", @case_request.attributes.slice(:source, :category))

        redirect_to support_case_request_path(@case_request)
      else
        render :new
      end
    end

    def submit
    end

  private

    def form_params
      params.require(:case_request).permit(
        :organisation_id,
        :organisation_type,
        :first_name,
        :last_name,
        :email,
        :phone_number,
        :extension_number,
        :discovery_method,
        :discovery_method_other_text,
        :category_id,
        :query_id,
        :source,
        :request_text,
        :other_category,
        :other_query,
        :procurement_amount,
      )
    end
  end
end
