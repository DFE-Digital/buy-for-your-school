require "rails_helper"

describe "Schools endpoints" do
  before { agent_is_signed_in }

  describe "GET /schools" do
    context "when requesting HTML type" do
      it "is not supported" do
        expect { get support_schools_path }.to raise_error(ActionController::UnknownFormat)
      end
    end

    context "when requesting JSON type" do
      let(:response_json) { JSON.parse(response.body) }

      before do
        26.times do |i|
          create(:support_organisation, urn: "123#{i}0#{i}")
        end
      end

      it "only returns 25 rows in total" do
        get support_schools_path(format: :json, q: "123")
        expect(response_json.length).to eq(25)
      end

      context "when supplying a query string of 1234" do
        it "only returns organisations which URN starts with 1234" do
          get support_schools_path(format: :json, q: "1234")

          result_urns = response_json.map { |result| result["urn"] }
          all_urns_start_with_1234 = result_urns.all? { |urn| urn.start_with?("1234") }

          expect(all_urns_start_with_1234).to be(true)
        end

        it "returns id, name, urn and postcode fields" do
          get support_schools_path(format: :json, q: "1234")

          keys = response_json.first.keys
          expect(keys).to include("id")
          expect(keys).to include("name")
          expect(keys).to include("urn")
          expect(keys).to include("postcode")
        end
      end
    end
  end
end
