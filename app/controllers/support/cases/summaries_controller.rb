module Support
  class Cases::SummariesController < ::Support::Cases::ApplicationController
    before_action :set_back_url, :form_url

    include HasDateParams

    def edit
      @case_summary = fields_pre_filled_in_params? ? current_case.summary(summary_params) : current_case.summary
      @case_summary.validate
    end

    def update
      @case_summary = CaseSummaryPresenter.new(current_case.summary(summary_params))
      if @case_summary.value.to_i > 99_999_999
        @case_summary.errors.add(:value, I18n.t("framework_request.errors.rules.procurement_amount.too_large"))
        render :edit
      elsif @case_summary.valid?
        return render :update if submit_action == "confirm"
        return render :edit   if submit_action == "change"

        @case_summary.save!

        # set status to ‘On hold’ when case level is L6 and procurement stage is Enquiry
        if @case_summary.support_case.support_level == "L6" && @case_summary.procurement_stage.title == "Enquiry"
          change_case_state(to: :on_hold)
        end
        # putting a redirect path in based on roles for now - this may change if a new form for CEC is created
        redirect_path
      else
        render :edit
      end
    end

  private

    def set_back_url
      @back_url = if submit_action == "confirm"
                    if (current_agent.roles & %w[cec cec_admin]).any?
                      cec_case_edit_summary_path(@current_case, case_summary: form_params)
                    else
                      edit_support_case_summary_path(@current_case, case_summary: form_params)
                    end
                  elsif (current_agent.roles & %w[cec cec_admin]).any?
                    cec_onboarding_case_path(@current_case, anchor: "case-details")
                  else
                    support_case_path(@current_case, anchor: "case-details")
                  end
    end

    def form_url
      @form_url = if (current_agent.roles & %w[cec cec_admin]).any?
                    cec_case_update_summary_path(@current_case)
                  else
                    support_case_summary_path(@current_case)
                  end
    end

    def submit_action
      params[:button]
    end

    def redirect_path
      if (current_agent.roles & %w[cec cec_admin]).any?
        redirect_to cec_onboarding_case_path(@current_case, anchor: "case-details")
      else
        redirect_to support_case_path(@current_case, anchor: "case-details")
      end
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
        :project,
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
