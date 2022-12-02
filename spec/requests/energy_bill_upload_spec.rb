require "rails_helper"

describe "Uploading energy bills" do
  it "saves the uploaded files as pending records" do
    post upload_your_bill_upload_framework_requests_path, params: { file: fixture_file_upload("text-file.txt") }
    energy_bill = EnergyBill.pending.last
    expect(energy_bill.filename).to eq("text-file.txt")
    expect(energy_bill.request_for_help_form).not_to be_nil
  end
end
