require "rails_helper"

describe "Uploading energy bills" do
  it "saves the uploaded files as pending records" do
    post upload_bill_uploads_framework_requests_path, params: { file: fixture_file_upload("text-file.txt") }
    energy_bill = EnergyBill.pending.last
    expect(energy_bill.filename).to eq("text-file.txt")
    expect(energy_bill.framework_request).not_to be_nil
  end

  it "returns the id of the saved energy bill" do
    post upload_bill_uploads_framework_requests_path, params: { file: fixture_file_upload("text-file.txt") }
    energy_bill = EnergyBill.pending.last
    expect(JSON.parse(response.body)["file_id"]).to eq(energy_bill.id)
  end

  it "removes energy bills" do
    post upload_bill_uploads_framework_requests_path, params: { file: fixture_file_upload("text-file.txt") }
    energy_bill = EnergyBill.pending.last

    delete remove_bill_uploads_framework_requests_path, params: { file_id: energy_bill.id }
    expect(EnergyBill.find_by(id: energy_bill.id)).to be_nil
  end

  context "when the uploaded file is infected" do
    before { Rails.configuration.clamav_scanner = ClamavRest::MockScanner.new(is_safe: false) }

    it "returns an error message" do
      post upload_bill_uploads_framework_requests_path, params: { file: fixture_file_upload("text-file.txt") }
      expect(JSON.parse(response.body)["error"]).to eq("virus detected")
      expect(response.status).to eq(422)
    end

    it "does not save the file" do
      post upload_bill_uploads_framework_requests_path, params: { file: fixture_file_upload("text-file.txt") }
      expect(EnergyBill.count).to be_zero
    end
  end
end
