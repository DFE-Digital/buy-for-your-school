module SignInHelpers
  def user_exists_in_dfe_sign_in(dsi_uid: SecureRandom.uuid)
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      uid: dsi_uid,
      credentials: {
        id_token: "a-long-secret-given-by-dsi-to-use-to-sign-the-user-out-of-dsi-as-a-whole"
      }
    )
  end

  def user_sign_in_attempt_fails(dsi_uid: SecureRandom.uuid)
    OmniAuth.config.mock_auth[:dfe] = :invalid_credentials
  end

  def user_starts_the_journey
    visit dashboard_path
    click_link I18n.t("dashboard.create.link")
  end

  def user_signs_in_and_starts_the_journey
    user_exists_in_dfe_sign_in
    user_starts_the_journey
  end

  def user_is_signed_in(user: anything)
    allow_any_instance_of(FindOrCreateUserFromSession)
      .to receive(:call)
      .and_return(user)
  end
end
