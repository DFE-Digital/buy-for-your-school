require "rails_helper"

describe "Organisations API" do
  describe "GET /support/organisations.json" do
    subject(:json_response) { JSON.parse(response.body) }

    before do
      agent_is_signed_in

      data = [
        ["The Aldgate School", "100000", "NW3 5DE"],
        ["Thomas Brook Centre", "100005", "WC1N 2NY"],
        ["CCfL Key Stage 4 PRU", "100006", "NW3 2NY"],
        ["Camden Primary Pupil Referral Unit", "100007", "NW1 3EX"],
        ["Argyle Primary School", "100008", "WC1H 9EG"],
        ["Brookfield Primary School", "100111", "N19 5DH"],
        ["Edith Neville Primary School", "100113", "NW1 1DN"],
      ]
      data.each do |(name, urn, postcode)|
        create(:support_organisation, name:, urn:, address: { "postcode" => postcode })
      end
    end

    it "returns id, name, urn, postcode and formatted_name fields" do
      get support_organisations_path(format: :json, q: "100000")

      aldgate_school = Support::Organisation.find_by(urn: "100000")

      result = json_response.first
      expect(result["id"]).to eq(aldgate_school.id)
      expect(result["name"]).to eq("The Aldgate School")
      expect(result["urn"]).to eq("100000")
      expect(result["postcode"]).to eq("NW3 5DE")
      expect(result["formatted_name"]).to eq("100000 - The Aldgate School")
    end

    describe "searching by postcode" do
      before { get support_organisations_path(format: :json, q: "NW3") }

      it "returns organisations with partially matching postcodes" do
        expect(json_response).to include(hash_including("formatted_name" => "100000 - The Aldgate School"))
        expect(json_response).to include(hash_including("formatted_name" => "100006 - CCfL Key Stage 4 PRU"))
        expect(json_response).not_to include(hash_including("formatted_name" => "100007 - Camden Primary Pupil Referral Unit"))
      end
    end

    describe "searching by urn" do
      before { get support_organisations_path(format: :json, q: "011") }

      it "returns organisations with partially matching URNs" do
        expect(json_response).to include(hash_including("formatted_name" => "100111 - Brookfield Primary School"))
        expect(json_response).to include(hash_including("formatted_name" => "100113 - Edith Neville Primary School"))
        expect(json_response).not_to include(hash_including("formatted_name" => "100000 - The Aldgate School"))
      end
    end

    describe "searching by name" do
      before { get support_organisations_path(format: :json, q: "Brook") }

      it "returns organisations with partially matching URNs" do
        expect(json_response).to include(hash_including("formatted_name" => "100005 - Thomas Brook Centre"))
        expect(json_response).to include(hash_including("formatted_name" => "100111 - Brookfield Primary School"))
        expect(json_response).not_to include(hash_including("formatted_name" => "100113 - Edith Neville Primary School"))
      end
    end
  end
end
