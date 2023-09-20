module FrameworkRequests
  class EmailForm < BaseForm
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validate :email_is_not_personal

    attr_accessor :email

    def initialize(attributes = {})
      super
      @email ||= framework_request.email
    end

    def email_is_not_personal
      return unless email
      return if email.downcase.include?("@sky.learning.mat")

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
      found_invalid_domain = invalid_emails.find { |i| email.downcase.include?(i) }
      if found_invalid_domain.present?
        _, domain = email.split("@")
        errors.add(:email, I18n.t("support_request.errors.rules.email.invalid", domain: "@#{domain}"))
      end
    end
  end
end
