class CookiePreferencesController < ApplicationController
  skip_before_action :authenticate_user!

  # display cookies in use
  def show
    @form = CookiePreferencesForm.new(accepted_or_rejected: cookies['cookie_policy'])
  end

  # form to update preferences
  def edit
  end

  # save updates to preferences
  def update
    cookies[:cookie_policy] = { value: cookie_preferences_params[:accepted_or_rejected], expires: 1.year.from_now }

    user_has_accepted = cookie_preferences_params[:accepted_or_rejected] == "accepted"

    respond_to do |format|
      format.html { redirect_to cookie_preferences_path, notice: I18n.t("cookies.information.updated.success") }
      format.js   { render user_has_accepted ? :update_cookies_accepted : :update_cookies_rejected }
    end
  end

  private

  def cookie_preferences_params
    params.require(:cookie_preferences_form).permit(:accepted_or_rejected)
  end
end
