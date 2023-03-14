require "rails_helper"

describe CaseFiles::RenameFile do
  subject(:form) { described_class.new(attachment) }

  describe "#custom_name_with_extension" do
    let(:attachment) { double("email_attachment", file_name: "text.txt") }

    context "when the entered custom name has the filename in it already" do
      let(:custom_name) { "test file.txt" }

      it "only has one instance of the file extension" do
        expect(form.custom_name_with_extension(custom_name)).to eq("test file.txt")
      end
    end

    context "when the entered custom name has the filename in it multiple times" do
      let(:custom_name) { "test file.txt.txt.txt" }

      it "only has one instance of the file extension" do
        expect(form.custom_name_with_extension(custom_name)).to eq("test file.txt")
      end
    end

    context "when the entered custom name does not have the file extension in it at all" do
      let(:custom_name) { "test file" }

      it "puts in one instance of the file extension" do
        expect(form.custom_name_with_extension(custom_name)).to eq("test file.txt")
      end
    end
  end
end
