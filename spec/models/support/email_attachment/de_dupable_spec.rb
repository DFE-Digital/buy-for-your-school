describe Support::EmailAttachment::DeDupable do
  subject(:de_dupable) { Support::EmailAttachment }

  include_context "with duplicated email attachments"

  describe ".find_duplicates_of" do
    it "returns all instances of email attachments on a case where the file and filename are identical for the given email attachment" do
      expect(de_dupable.find_duplicates_of(case_1_attachment_1)).to match_array([case_1_attachment_1])
      expect(de_dupable.find_duplicates_of(case_1_attachment_2)).to match_array([case_1_attachment_2, case_1_attachment_3])
      expect(de_dupable.find_duplicates_of(case_1_attachment_3)).to match_array([case_1_attachment_2, case_1_attachment_3])
      expect(de_dupable.find_duplicates_of(case_2_attachment_1)).to match_array([case_2_attachment_1, case_2_attachment_2])
      expect(de_dupable.find_duplicates_of(case_2_attachment_2)).to match_array([case_2_attachment_1, case_2_attachment_2])
      expect(de_dupable.find_duplicates_of(case_2_attachment_3)).to match_array([case_2_attachment_3])
      # same file name, different checksum
      expect(de_dupable.find_duplicates_of(case_1_attachment_4)).to match_array([case_1_attachment_4])
    end
  end
end
