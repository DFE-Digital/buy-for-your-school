require "rails_helper"

RSpec.describe "Errors", type: :request do
  describe "internal_server_error" do
    it "the 500 endpoint returns the expected status and error message" do
      get "/500"
      expect(response).to have_http_status(:internal_server_error)
      # errors.internal_server_error.page_title
      expect(response.body).to include "Internal server error"
      # errors.internal_server_error.page_body
      expect(response.body).to include "Sorry, there is a problem with the service. Please try again later."
    end
  end

  describe "not_found" do
    it "the 404 endpoint returns the expected status and error message" do
      get "/404"
      expect(response).to have_http_status(:not_found)
      # errors.not_found.page_title
      expect(response.body).to include "Page not found"
      # errors.not_found.page_body
      expect(response.body).to include "Page not found. If you typed the web address, check it is correct. If you pasted the web address, check you copied the entire address."
    end
  end

  describe "unacceptable" do
    it "the 422 endpoint returns the expected status and error message" do
      get "/422"
      expect(response).to have_http_status(:unprocessable_entity)
      # errors.unacceptable.page_title
      expect(response.body).to include "Unacceptable request"
      # errors.unacceptable.page_body
      expect(response.body).to include "There was a problem with your request."
    end
  end
end
