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

  describe "unacceptable" do
    it "the 422 endpoint returns the expected status" do
      get "/422"
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
