module Support
  class Cases::OnHoldsController < Cases::ApplicationController
    def create
      if current_case.may_hold?
        change_case_state(to: :on_hold)
        byebug
        redirect_to support_case_path(current_case, anchor: "case-history"),
                    notice: I18n.t("support.case_on_hold.flash.created")
      else
        redirect_to support_case_path(current_case),
                    notice: I18n.t("support.case_on_hold.flash.error")
      end
    end
  end
end
