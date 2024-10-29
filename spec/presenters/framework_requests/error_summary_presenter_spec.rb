require "rails_helper"

describe FrameworkRequests::ErrorSummaryPresenter do
  subject(:presenter) { described_class.new(error_messages, framework_request.id, user) }

  let(:user) { build(:user) }
  let(:framework_request) { create(:framework_request, first_name:, last_name:, email:, org_id:, category:, procurement_amount:, message_body:, origin:) }
  let(:error_messages) do
    framework_request.valid?(:complete)
    framework_request.errors.messages
  end

  let(:first_name) { "Test" }
  let(:last_name) { "User" }
  let(:email) { "test@email.com" }
  let(:org_id) { "123" }
  let(:category) { create(:request_for_help_category) }
  let(:procurement_amount) { 235.12 }
  let(:message_body) { "Support needed" }
  let(:origin) { :website }

  describe "#formatted_error_messages" do
    context "when first_name is invalid" do
      let(:first_name) { nil }

      it "returns a message with a link to the name edit page" do
        expect(presenter.formatted_error_messages).to contain_exactly([:first_name, "Enter your first name", "/procurement-support/#{framework_request.id}/name/edit"])
      end
    end

    context "when last_name is invalid" do
      let(:last_name) { nil }

      it "returns a message with a link to the name edit page" do
        expect(presenter.formatted_error_messages).to contain_exactly([:last_name, "Enter your last name", "/procurement-support/#{framework_request.id}/name/edit"])
      end
    end

    context "when email is invalid" do
      let(:email) { nil }

      it "returns a message with a link to the email edit page" do
        expect(presenter.formatted_error_messages).to contain_exactly([:email, "Enter your email address", "/procurement-support/#{framework_request.id}/email/edit"])
      end
    end

    context "when organisation is invalid" do
      let(:org_id) { nil }

      context "and the user is signed in" do
        let(:user) { build(:user, :many_supported_schools) }

        it "returns a message with a link to the organisation selection page" do
          expect(presenter.formatted_error_messages).to contain_exactly([:org_id, "Select the school or group you want help buying for", "/procurement-support/#{framework_request.id}/select_organisation/edit"])
        end
      end

      context "and the user is a guest" do
        let(:user) { build(:guest) }

        it "returns a message with a link to the organisation search page" do
          expect(presenter.formatted_error_messages).to contain_exactly([:org_id, "Select the school or group you want help buying for", "/procurement-support/#{framework_request.id}/search_for_organisation/edit"])
        end
      end
    end

    context "when category is invalid" do
      let(:category) { nil }

      it "returns a message with a link to the category edit page" do
        expect(presenter.formatted_error_messages).to contain_exactly([:category, "Select the type of goods or service you need", "/procurement-support/#{framework_request.id}/category/edit"])
      end
    end

    context "when procurement_amount is invalid" do
      let(:procurement_amount) { nil }

      it "returns a message with a link to the procurement amount edit page" do
        expect(presenter.formatted_error_messages).to contain_exactly([:procurement_amount, "Enter how much the school will be spending. The number must be greater than 0.", "/procurement-support/#{framework_request.id}/procurement_amount/edit"])
      end
    end

    context "when message_body is invalid" do
      let(:message_body) { nil }

      it "returns a message with a link to the request description edit page" do
        expect(presenter.formatted_error_messages).to contain_exactly([:message_body, "You must tell us how we can help", "/procurement-support/#{framework_request.id}/message/edit"])
      end
    end

    context "when origin is invalid" do
      let(:origin) { nil }

      it "returns a message with a link to the origin edit page" do
        expect(presenter.formatted_error_messages).to contain_exactly([:origin, "Select where you heard about the service", "/procurement-support/#{framework_request.id}/origin/edit"])
      end
    end
  end
end
