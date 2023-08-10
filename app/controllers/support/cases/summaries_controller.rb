module Support
  class Cases::SummariesController < ::Support::Cases::ApplicationController
    before_action :set_back_url

    include Concerns::HasDateParams

    def edit
      @case_summary = fields_pre_filled_in_params? ? current_case.summary(summary_params) : current_case.summary
      @case_summary.validate
    end

    def update
      @case_summary = CaseSummaryPresenter.new(current_case.summary(summary_params))

      if @case_summary.valid?
        return render :update if submit_action == "confirm"
        return render :edit   if submit_action == "change"

        @case_summary.save!

        redirect_to support_case_path(@current_case, anchor: "case-details")
      else
        render :edit
      end
    end

  private

    def set_back_url
      @back_url = if submit_action == "confirm"
                    edit_support_case_summary_path(@current_case, case_summary: form_params)
                  else
                    support_case_path(@current_case, anchor: "case-details")
                  end
    end

    def submit_action
      params[:button]
    end

    def fields_pre_filled_in_params?
      form_params.present?
    rescue ActionController::ParameterMissing
      false
    end

    def summary_params
      form_params
        .except("next_key_date(3i)", "next_key_date(2i)", "next_key_date(1i)")
        .merge(next_key_date: date_param(:case_summary, :next_key_date).compact_blank)
        .compact_blank
    end

    def form_params
      params.require(:case_summary).permit(
        :request_text,
        :request_type,
        :category_id,
        :other_category,
        :query_id,
        :other_query,
        :source,
        :value,
        :support_level,
        :procurement_stage_id,
        :next_key_date,
        :next_key_date_description,
        :submit,
      )
    end
  end
end
