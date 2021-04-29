require "rails_helper"

RSpec.describe "Errors", type: :request do
  describe "internal_server_error" do
    it "the 500 endpoint returns the expected status and error message" do
      get "/500"
      expect(response).to have_http_status(:internal_server_error)
      expect(response.body).to include(I18n.t("errors.internal_server_error.page_title"))
      expect(response.body).to include(I18n.t("errors.internal_server_error.page_body"))
    end
  end

  describe "not_found" do
    it "the 404 endpoint returns the expected status and error message" do
      get "/404"
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include(I18n.t("errors.not_found.page_title"))
      expect(response.body).to include(I18n.t("errors.not_found.page_body"))
    end
  end

  describe "unacceptable" do
    it "the 422 endpoint returns the expected status and error message" do
      get "/422"
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(I18n.t("errors.unacceptable.page_title"))
      expect(response.body).to include(I18n.t("errors.unacceptable.page_body"))
    end
  end
end
