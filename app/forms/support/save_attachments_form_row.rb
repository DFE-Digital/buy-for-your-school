module Support
  class SaveAttachmentsFormRow < ::Support::CaseAttachment
    attr_reader :selected

    validates :name, uniqueness: {
      scope: :support_case_id,
      message: I18n.t("save_attachments_form.errors.rules.name.already_taken"),
    }
    validates :description, presence: {
      message: I18n.t("save_attachments_form.errors.rules.description.missing"),
    }

    delegate :file_name, to: :email_attachment

    before_validation do
      self.name = email_attachment&.file_name if name.blank?
    end

    def selected=(value)
      @selected = value == "1"
    end
  end
end
