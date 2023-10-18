describe EmailAttachment::Hideable do
  include_context "with duplicated email attachments"

  describe "#hide" do
    it "sets the hidden flag to true on all copies of that file" do
      expect { case_1_attachment_1.hide }.to change { case_1_attachment_1.reload.hidden }.from(false).to(true) \
        .and not_change { case_1_attachment_2.reload.hidden }
        .and not_change { case_1_attachment_3.reload.hidden }
        .and(not_change { case_2_attachment_2.reload.hidden })

      expect { case_2_attachment_1.hide }.to change { case_2_attachment_1.reload.hidden }.from(false).to(true) \
        .and change { case_2_attachment_2.reload.hidden }.to(true)
        .and(not_change { case_2_attachment_3.reload.hidden })
    end
  end
end
