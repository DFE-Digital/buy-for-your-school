module Support
  class Messages::ReplyFormSchema < ::Support::Schema
    config.messages.top_namespace = :message_reply_form

    params do
      required(:body).value(:string)
      optional(:subject).value(:string)
      optional(:to_recipients)
      optional(:cc_recipients)
      optional(:bcc_recipients)
      optional(:attachments)
      optional(:case_ref)
    end

    rule(:body) do
      key(:body).failure(:missing) if value.blank?
    end

    rule(:subject) do
      key(:subject).failure(:missing) if key? && value.blank?
    end

    rule do
      base.failure(:no_recipients) if (key?(:to_recipients) && values[:to_recipients].empty?) && (key?(:cc_recipients) && values[:cc_recipients].empty?) && (key?(:bcc_recipients) && values[:bcc_recipients].empty?)
      base.failure(:invalid_to_recipients) if key?(:to_recipients) && !values[:to_recipients].empty? && contains_invalid_emails?(values[:to_recipients])
      base.failure(:invalid_cc_recipients) if key?(:cc_recipients) && !values[:cc_recipients].empty? && contains_invalid_emails?(values[:cc_recipients])
      base.failure(:invalid_bcc_recipients) if key?(:bcc_recipients) && !values[:bcc_recipients].empty? && contains_invalid_emails?(values[:bcc_recipients])
      base.failure(:no_ref, case_ref: values[:case_ref]) if (key?(:subject) && values[:subject].present? && values[:subject].match(/([0-9]{6,6})/).to_a.last.blank?) && (key?(:body) && values[:body].present? && values[:body].match(/Your reference number is: ([0-9]{6,6})\./).to_a.last.blank?)
    end

    rule(:attachments) do
      if value.present?
        all_files_safe = Array(value).all? { |upload_file| Support::VirusScanner.uploaded_file_safe?(upload_file) }
        key(:attachments).failure(:infected) unless all_files_safe

        all_files_allowed_type = Array(value).all? { |upload_file| upload_file.content_type.in?(OUTLOOK_MESSAGE_FILE_TYPE_ALLOW_LIST) }
        key(:attachments).failure(:incorrect_file_type) unless all_files_allowed_type
      end
    end

  private

    def contains_invalid_emails?(recipients)
      array = JSON.parse(recipients)
      array.any? { |r| !URI::MailTo::EMAIL_REGEXP.match?(r) }
    end
  end
end
