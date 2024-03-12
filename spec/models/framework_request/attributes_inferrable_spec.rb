require "rails_helper"

describe FrameworkRequest::AttributesInferrable do
  subject(:attributes_inferrable) { create(:framework_request, user: nil, first_name: nil, last_name: nil, email: nil, org_id: nil, group: false) }

  describe ".create_with_inferred_attributes!" do
    context "when the user is a guest" do
      let(:user) { UserPresenter.new(build(:guest)) }

      it "creates a new framework request with no inferred information" do
        expect { FrameworkRequest.create_with_inferred_attributes!(user) }.to change(FrameworkRequest, :count).from(0).to(1)
        expect(FrameworkRequest.first.user).to be_nil
        expect(FrameworkRequest.first.first_name).to be_nil
        expect(FrameworkRequest.first.last_name).to be_nil
        expect(FrameworkRequest.first.email).to be_nil
        expect(FrameworkRequest.first.org_id).to be_nil
        expect(FrameworkRequest.first.group).to eq(false)
      end
    end

    context "when the user is signed in" do
      let(:user) { UserPresenter.new(build(:user, :one_supported_group)) }

      it "creates a new framework request with inferred information" do
        expect { FrameworkRequest.create_with_inferred_attributes!(user) }.to change(FrameworkRequest, :count).from(0).to(1)
        expect(FrameworkRequest.first.user).to eq(user.to_model)
        expect(FrameworkRequest.first.first_name).to eq("first_name")
        expect(FrameworkRequest.first.last_name).to eq("last_name")
        expect(FrameworkRequest.first.email).to eq("test@test")
        expect(FrameworkRequest.first.org_id).to eq("2314")
        expect(FrameworkRequest.first.group).to eq(true)
      end
    end
  end

  describe "#set_inferred_attributes!" do
    context "when the user is a guest" do
      let(:user) { UserPresenter.new(build(:guest)) }

      it "makes no changes to inferrable attributes" do
        expect { attributes_inferrable.set_inferred_attributes!(user) }.to not_change(attributes_inferrable, :user)
          .and not_change(attributes_inferrable, :first_name)
          .and not_change(attributes_inferrable, :last_name)
          .and not_change(attributes_inferrable, :email)
          .and not_change(attributes_inferrable, :org_id)
          .and not_change(attributes_inferrable, :group)
      end
    end

    context "when the user is signed in" do
      context "and belongs to one organisation" do
        let(:user) { UserPresenter.new(build(:user, :one_supported_school)) }

        it "sets inferrable attributes" do
          expect { attributes_inferrable.set_inferred_attributes!(user) }.to change(attributes_inferrable, :user)
            .and change(attributes_inferrable, :first_name).from(nil).to("first_name")
            .and change(attributes_inferrable, :last_name).from(nil).to("last_name")
            .and change(attributes_inferrable, :email).from(nil).to("test@test")
            .and change(attributes_inferrable, :org_id).from(nil).to("100253")
            .and not_change(attributes_inferrable, :group).from(false)
        end
      end

      context "and belongs to one group" do
        let(:user) { UserPresenter.new(build(:user, :one_supported_group)) }

        it "sets inferrable attributes" do
          expect { attributes_inferrable.set_inferred_attributes!(user) }.to change(attributes_inferrable, :user)
            .and change(attributes_inferrable, :first_name).from(nil).to("first_name")
            .and change(attributes_inferrable, :last_name).from(nil).to("last_name")
            .and change(attributes_inferrable, :email).from(nil).to("test@test")
            .and change(attributes_inferrable, :org_id).from(nil).to("2314")
            .and change(attributes_inferrable, :group).from(false).to(true)
        end
      end

      context "and belongs to multiple organisations" do
        let(:user) { UserPresenter.new(build(:user, :many_supported_schools)) }

        it "sets inferrable attributes" do
          expect { attributes_inferrable.set_inferred_attributes!(user) }.to change(attributes_inferrable, :user)
            .and change(attributes_inferrable, :first_name).from(nil).to("first_name")
            .and change(attributes_inferrable, :last_name).from(nil).to("last_name")
            .and change(attributes_inferrable, :email).from(nil).to("test@test")
            .and not_change(attributes_inferrable, :org_id)
            .and not_change(attributes_inferrable, :group)
        end
      end

      context "and belongs to an unsupported organisation" do
        let(:user) { UserPresenter.new(build(:user, :no_supported_schools)) }

        it "sets inferrable attributes" do
          expect { attributes_inferrable.set_inferred_attributes!(user) }.to change(attributes_inferrable, :user)
            .and change(attributes_inferrable, :first_name).from(nil).to("first_name")
            .and change(attributes_inferrable, :last_name).from(nil).to("last_name")
            .and change(attributes_inferrable, :email).from(nil).to("test@test")
            .and not_change(attributes_inferrable, :org_id)
            .and not_change(attributes_inferrable, :group)
        end
      end
    end
  end
end
