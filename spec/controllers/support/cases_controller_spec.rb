# frozen_string_literal: true

RSpec.describe Support::CasesController, type: :controller do
  describe "FilterParameters concern" do
    let(:filters) { { agent: "testing", level: "1" } }
    let(:tab) { :filter_my_cases_form }

    before { agent_is_signed_in }

    it "caches the filters in the session" do
      expect(session[tab]).to be_nil

      get :index, params: { tab => filters }

      expect(session[tab]).to eq(filters)
    end

    context "when filtering cases" do
      before do
        session[tab] = filters
      end

      it "removes cached filters when the clear param is passed" do
        get :index, params: { clear: true }

        expect(session[tab]).to be_nil
      end

      it "filter parameters replace those cached in the session" do
        get :index, params: { tab => { agent: "another", level: "2" } }

        expect(session[tab]).to eq({ agent: "another", level: "2" })
      end
    end
  end
end
