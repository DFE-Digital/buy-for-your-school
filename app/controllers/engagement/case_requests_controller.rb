module Engagement
  class CaseRequestsController < ApplicationController
    before_action :case_request, only: %i[show edit update submit]

    def create
      @case_request = CaseRequest.new(source: :engagement_and_outreach_cms, creation_source: :engagement_and_outreach_team, created_by: current_agent)
      @case_request.save!(validate: false)
      redirect_to edit_engagement_case_request_path(@case_request)
    end

    def show; end

    def edit
      @back_url = @case_request.completed? ? engagement_case_request_path(@case_request) : engagement_cases_path
    end

    def update
      @back_url = @case_request.completed? ? engagement_case_request_path(@case_request) : engagement_cases_path
      @case_request.assign_attributes(form_params)

      if @case_request.valid?
        @case_request.save!
        redirect_to(@case_request.eligible_for_school_picker? && @case_request.school_urns.empty? ? edit_engagement_case_request_school_picker_path(@case_request) : engagement_case_request_path(@case_request))
      else
        render :edit
      end
    end

    def submit
      @case_request.create_case
      redirect_to engagement_cases_path
    end

  private

    def case_request
      @case_request = CaseRequest.find_by(id: params[:id])
    end

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
        :request_text,
        :other_category,
        :other_query,
        :procurement_amount,
      )
    end
  end
end
