module Support
  module Cases
    class QuickEditsController < Cases::ApplicationController
      include HasDateParams

      before_action :back_url, only: %i[edit update]
      helper_method :back_to_param

      def edit
        @case_quick_edit = current_case.quick_editor
      end

      def update
        @case_quick_edit = current_case.quick_editor(quick_edit_params)

        if @case_quick_edit.valid?
          @case_quick_edit.save!
          redirect_to redirect_to_url, notice: "Case updated"
        else
          render :edit
        end
      end

    private

      def cec_namespace?
        (current_agent.roles & %w[cec cec_admin]).any?
      end

      def portal_namespace
        (current_agent.roles & %w[cec cec_admin]).any? ? "cec" : "support"
      end

      helper_method def portal_case_quick_edit_path
        send("#{portal_namespace}_case_quick_edit_path")
      end

      def back_url
        @back_url = url_from(back_link_param) || (cec_namespace? ? cec_onboarding_cases_path : support_cases_path)
      end

      def redirect_to_url
        url_from(back_link_param(back_to_param)) || (cec_namespace? ? cec_onboarding_cases_path : support_cases_path)
      end

      def back_to_param
        params[:back_to] || params.dig(:case_quick_edit, :back_to)
      end

      def quick_edit_params
        form_params
          .except("next_key_date(3i)", "next_key_date(2i)", "next_key_date(1i)")
          .merge(next_key_date: date_param(:case_quick_edit, :next_key_date).compact_blank)
          .compact_blank
      end

      def form_params
        params.require(:case_quick_edit).permit(:note, :support_level, :procurement_stage_id, :with_school, :next_key_date, :next_key_date_description)
      end
    end
  end
end
