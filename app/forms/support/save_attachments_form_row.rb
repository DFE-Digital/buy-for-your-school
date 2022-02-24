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
      self.name = file_name_to_save
    end

    def selected=(value)
      @selected = value == "1"
    end

    def file_name_to_save
      file_extension = ActiveStorage::Filename.new(file_name).extension_with_delimiter
      potential_name = name.presence || file_name

      if potential_name.ends_with?(file_extension)
        potential_name
      else
        potential_name.concat(file_extension)
      end
    end
  end
end
