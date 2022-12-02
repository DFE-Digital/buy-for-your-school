require "rails_helper"

describe "Uploading energy bills" do
  it "saves the uploaded files as pending records" do
    post upload_your_bill_upload_framework_requests_path, params: { file: fixture_file_upload("text-file.txt") }
    energy_bill = EnergyBill.pending.last
    expect(energy_bill.filename).to eq("text-file.txt")
    expect(energy_bill.framework_request).not_to be_nil
  end

  it "returns the id of the saved energy bill" do
    post upload_your_bill_upload_framework_requests_path, params: { file: fixture_file_upload("text-file.txt") }
    energy_bill = EnergyBill.pending.last
    expect(JSON.parse(response.body)["energy_bill_id"]).to eq(energy_bill.id)
  end

  it "removes energy bills" do
    post upload_your_bill_upload_framework_requests_path, params: { file: fixture_file_upload("text-file.txt") }
    energy_bill = EnergyBill.pending.last

    delete upload_your_bill_remove_framework_requests_path, params: { id: energy_bill.id }
    expect(EnergyBill.find_by(id: energy_bill.id)).to be_nil
  end
end
