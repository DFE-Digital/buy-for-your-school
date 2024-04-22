RSpec.describe Frameworks::FrameworkDatum, type: :model do
  describe "#to_csv" do
    it "includes headers" do
      expect(described_class.to_csv).to eql(
        "framework_id,source,status,name,short_name,url,reference,provider_name,provider_short_name,provider_contact_name,provider_contact_email,provider_start_date,provider_end_date,dfe_start_date,dfe_review_date,sct_framework_owner,sct_framework_provider_lead,procops_lead_name,procops_lead_email,e_and_o_lead_name,e_and_o_lead_email,created_at,updated_at,dps,lot,provider_reference,faf_added_date,faf_end_date,categories,has_evaluation\n",
      )
    end
  end
end
