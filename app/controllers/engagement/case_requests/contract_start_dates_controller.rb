module Engagement
  module CaseRequests
    class ContractStartDatesController < ApplicationController
      include HasDateParams
      before_action :case_request, only: %i[edit update]
      before_action :back_url

      def edit
        @contract_start_dater = @case_request.contract_start_dater
      end

      def update
        @contract_start_dater = @case_request.contract_start_dater(contract_start_date_params)

        if @contract_start_dater.valid?
          @contract_start_dater.save!
          redirect_to engagement_case_request_path(@case_request)
        else
          render :edit
        end
      end

    private

      def back_url
        @back_url = params[:source] == "change_link" ? engagement_case_request_path(@case_request) : determine_back_path
      end

      def determine_back_path
        if @case_request.eligible_for_school_picker? && @case_request.school_urns.count > 1
          edit_engagement_case_request_same_supplier_path(@case_request)
        elsif @case_request.eligible_for_school_picker? && @case_request.school_urns.count < 2
          edit_engagement_case_request_school_picker_path(@case_request)
        else
          edit_engagement_case_request_path(@case_request)
        end
      end

      def case_request
        @case_request = CaseRequest.find_by(id: params[:id])
      end

      def form_params
        params.fetch(:case_request, {}).permit(:contract_start_date_known, :contract_start_date)
      end

      def contract_start_date_params
        form_params
          .except("contract_start_date(3i)", "contract_start_date(2i)", "contract_start_date(1i)")
          .merge(contract_start_date: date_param(:case_request, :contract_start_date).compact_blank)
          .to_h
          .symbolize_keys
      end
    end
  end
end
