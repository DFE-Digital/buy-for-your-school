class EmailAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if options[:format]
      return if URI::MailTo::EMAIL_REGEXP.match?(value)

      record.errors.add attribute, :invalid_email_address, **options
    end

    if options[:school_email]
      return unless value
      return if value.downcase.include?("@sky.learnmat.uk")

      invalid_emails = ["@gmail.",
                        "@yahoo.",
                        "@aol.",
                        "@hotmail.",
                        "@mail.",
                        "@outlook.",
                        "@icloud.",
                        "@lycos.",
                        "@sky.",
                        "@btinternet",
                        "@talktalk",
                        "@virginmedia",
                        "@plus.net",
                        "@btopenworld",
                        "@talk21",
                        "@live"]
      found_invalid_domain = invalid_emails.find { |i| value.downcase.include?(i) }
      if found_invalid_domain.present?
        _, domain = value.split("@")
        record.errors.add attribute, :not_school_email, domain: "@#{domain}"
      end
    end
  end
end
