module Support
  module Cases
    class QuickEditsController < Cases::ApplicationController
      before_action :back_url, only: %i[edit update]
      helper_method :back_to_param

      def edit
        @case_quick_edit = current_case.quick_editor
      end

      def update
        @case_quick_edit = current_case.quick_editor(form_params)

        if @case_quick_edit.valid?
          @case_quick_edit.save!
          redirect_to redirect_to_url, notice: "Case updated"
        else
          render :edit
        end
      end

    private

      def back_url
        @back_url = url_from(back_link_param) || support_cases_path
      end

      def redirect_to_url
        url_from(back_link_param(back_to_param)) || support_cases_path
      end

      def back_to_param
        params[:back_to] || params.dig(:case_quick_edit, :back_to)
      end

      def form_params
        params.require(:case_quick_edit).permit(:note, :support_level, :procurement_stage_id)
      end
    end
  end
end
