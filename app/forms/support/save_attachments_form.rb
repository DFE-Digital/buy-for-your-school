module Support
  class SaveAttachmentsForm
    include ActiveModel::Model
    attr_accessor :attachments

    def self.from_email(email)
      attachments = email.attachments.each_with_index.map do |attachment, i|
        [i, { support_email_attachment_id: attachment.id, support_case_id: email.case_id }]
      end

      new(attachments_attributes: attachments.to_h)
    end

    def valid?
      selected_attachments.all?(&:valid?).tap do
        errors.add(:base, I18n.t("save_attachments_form.errors.rules.base"))
      end
    end

    def attachments_attributes=(attributes)
      @attachments = attributes.values.map do |attachment|
        SaveAttachmentsFormRow.new(**attachment)
      end
    end

    def selected_attachments
      attachments.select(&:selected)
    end

    def save_attachments
      selected_attachments.each(&:save!)
    end
  end
end
