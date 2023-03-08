module CaseFiles
  class HideAttachment
    def call(attachment_id:)
      attachment = Support::EmailAttachment.find(attachment_id)

      Support::EmailAttachment.find_duplicates_of(attachment).update!(hidden: true)
    end
  end
end
