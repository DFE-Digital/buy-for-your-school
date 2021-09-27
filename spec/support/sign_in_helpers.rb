module SignInHelpers
  # TODO: rename `user_exists_in_dfe_sign_in` to `mock_dsi_callback`
  def user_exists_in_dfe_sign_in(user: build(:user))

    # stub CreateUser call to DSI API for roles and orgs
    dsi_client = instance_double(::Dsi::Client)
    allow(Dsi::Client).to receive(:new).and_return(dsi_client)

    allow(dsi_client).to receive(:roles).and_return(user.roles)
    allow(dsi_client).to receive(:orgs).and_return(user.orgs)

    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      provider: :dfe,
      uid: user.dfe_sign_in_uid,
      info: {
        name: user.full_name,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
      },
      credentials: {
        id_token: "a-long-secret-given-by-dsi-to-use-to-sign-the-user-out-of-dsi-as-a-whole",
      },
      extra: {
        raw_info: {
          organisation: {
            id: "23F20E54-79EA-4146-8E39-18197576F023",
          },
        },
      },
    )
  end

  def user_is_signed_in(user: build(:user))
    # stub CreateUser call to DSI API for roles and orgs
    dsi_client = instance_double(::Dsi::Client)
    allow(Dsi::Client).to receive(:new).and_return(dsi_client)

    allow(dsi_client).to receive(:roles).and_return(user.roles)
    allow(dsi_client).to receive(:orgs).and_return(user.orgs)

    allow_any_instance_of(::CurrentUser).to receive(:call).with(anything).and_return(user)
  end

  def has_valid_api_token
    allow_any_instance_of(Api::Contentful::BaseController).to receive(:authenticate_api_user!).and_return(true)
  end
end
