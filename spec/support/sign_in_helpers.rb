module SignInHelpers
  def user_exists_in_dfe_sign_in(dsi_uid: SecureRandom.uuid)
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      uid: dsi_uid,
      credentials: {
        id_token: "a-long-secret-given-by-dsi-to-use-to-sign-the-user-out-of-dsi-as-a-whole",
      },
    )
  end

  def user_is_signed_in(user: build(:user))
    allow_any_instance_of(FindOrCreateUserFromSession).to receive(:call).and_return(user)
  end
end
