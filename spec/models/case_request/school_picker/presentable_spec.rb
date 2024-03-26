require "rails_helper"

describe CaseRequest::SchoolPicker::Presentable do
  describe "#organisation_type" do
    subject(:presentable) { CaseRequest::SchoolPicker.new(case_request:) }

    let(:case_request) { create(:case_request, organisation:) }

    context "when the organisation is an establishment group" do
      let(:organisation) { create(:support_establishment_group) }

      it "returns 'academy trust or federation'" do
        expect(presentable.organisation_type).to eq("academy trust or federation")
      end
    end

    context "when the organisation is a local authority" do
      let(:organisation) { create(:local_authority) }

      it "returns 'local authority'" do
        expect(presentable.organisation_type).to eq("local authority")
      end
    end
  end
end
