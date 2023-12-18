module Engagement
  module CaseRequests
    class SameSuppliersController < ApplicationController
      before_action :case_request, only: %i[edit update]
      before_action :back_url

      def edit
        @same_supplierer = @case_request.same_supplierer
      end

      def update
        @same_supplierer = @case_request.same_supplierer(same_supplier_used: form_params[:same_supplier_used])

        if @same_supplierer.valid?
          @same_supplierer.save!
          if @case_request.category.is_energy_or_services?
            redirect_to edit_engagement_case_request_contract_start_date_path(@case_request)
          else
            redirect_to engagement_case_request_path(@case_request)
          end
        else
          render :edit
        end
      end

    private

      def back_url
        @back_url = params[:source] == "change_link" ? engagement_case_request_path(@case_request) : edit_engagement_case_request_school_picker_path(@case_request)
      end

      def case_request
        @case_request = CaseRequest.find_by(id: params[:id])
      end

      def form_params
        params.fetch(:case_request, {}).permit(:same_supplier_used)
      end
    end
  end
end
