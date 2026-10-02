RSpec.describe "Errors", type: :request do
  describe "internal_server_error" do
    it "the 500 endpoint returns the expected status" do
      get "/500"
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe "not_found" do
    it "the 404 endpoint returns the expected status" do
      get "/404"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "not_acceptable" do
    around do |example|
      original_show_exceptions = Rails.application.env_config["action_dispatch.show_exceptions"]
      original_show_detailed_exceptions = Rails.application.env_config["action_dispatch.show_detailed_exceptions"]
      original_consider_all_requests_local = Rails.application.env_config["consider_all_requests_local"]

      Rails.application.env_config["action_dispatch.show_exceptions"] = :all
      Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = false
      Rails.application.env_config["consider_all_requests_local"] = false

      example.run
    ensure
      Rails.application.env_config["action_dispatch.show_exceptions"] = original_show_exceptions
      Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = original_show_detailed_exceptions
      Rails.application.env_config["consider_all_requests_local"] = original_consider_all_requests_local
    end

    it "the 406 endpoint returns the expected status and error page" do
      get "/406"
      expect(response).to have_http_status(:not_acceptable)
    end

    it "returns the 406 page when an HTML page is requested as plain text" do
      get "/", headers: { "Accept" => "text/plain" }

      expect(response).to have_http_status(:not_acceptable)
      expect(response.body).to include(I18n.t("errors.unacceptable.page_title"))
    end

    it "ignores unknown format exceptions in Rollbar" do
      expect(Rollbar.configuration.exception_level_filters["ActionController::UnknownFormat"]).to eq("ignore")
    end
  end

  describe "unacceptable" do
    it "the 422 endpoint returns the expected status" do
      get "/422"
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
