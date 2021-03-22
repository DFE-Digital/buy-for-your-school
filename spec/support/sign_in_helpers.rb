module SignInHelpers
  def user_exists_in_dfe_sign_in(dsi_uid: SecureRandom.uuid)
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      uid: dsi_uid
    )
  end

  def user_sign_in_attempt_fails(dsi_uid: SecureRandom.uuid)
    OmniAuth.config.mock_auth[:dfe] = :invalid_credentials
  end

  def user_signs_in_using_dfe_sign_in
    visit root_path
    click_link I18n.t("generic.button.start")
  end
end
