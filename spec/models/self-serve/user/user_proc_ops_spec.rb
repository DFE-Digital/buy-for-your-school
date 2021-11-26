RSpec.describe User, type: :model do
  around do |example|
    ClimateControl.modify(PROC_OPS_TEAM: "DfE Commercial Procurement Operations") { example.run }
  end

  describe "proc_ops" do
    before do
      create(:user,
             first_name: "test_proc_ops",
             orgs: [
               {
                 "id": "23F20E54-79EA-4146-8E39-18197576F023",
                 "name": "DfE Commercial Procurement Operations",
               },
             ])

      create(:user,
             first_name: "test_not_proc_ops",
             orgs: [
               {
                 "id": "23F20E54-79EA-4146-8E39-18197576F023",
                 "name": "Other organisation",
               },
             ])
    end

    it "returns Proc-Ops users only" do
      expect(described_class.proc_ops.count).to eq 1
      expect(described_class.proc_ops[0].first_name).to eq "test_proc_ops"
    end
  end
end
