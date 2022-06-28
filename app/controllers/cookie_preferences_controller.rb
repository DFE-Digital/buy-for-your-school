class CookiePreferencesController < ApplicationController
  skip_before_action :authenticate_user!

  # display cookies in use
  def show
  end

  # form to update preferences
  def edit
  end

  # save updates to preferences
  def update
    cookies[:cookie_consent] = { value: cookie_preferences_params[:accepted_or_rejected], expires: 1.year.from_now }

    if cookie_preferences_params[:accepted_or_rejected] == "accepted"
      render :update_cookies_accepted
    else
      render :update_cookies_rejected
    end
  end

  private

  def cookie_preferences_params
    params.require(:cookie_preferences_form).permit(:accepted_or_rejected)
  end
end
