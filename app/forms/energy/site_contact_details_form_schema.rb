# Site Contact Details Form
#
class Energy::SiteContactDetailsFormSchema < Schema
  config.messages.top_namespace = :site_contact_details_form

  params do
    required(:site_contact_first_name).value(:string, max_size?: 60)
    required(:site_contact_last_name).value(:string,  max_size?: 60)
    required(:site_contact_email).value(:string)
    required(:site_contact_phone).value(:string)
  end

  rule(:site_contact_first_name) do
    key.failure(:missing) if value.blank?
  end

  rule(:site_contact_email) do
    key.failure(:missing) if value.blank?
  end

  rule(:site_contact_email) do
    if key? && (value.blank? || !URI::MailTo::EMAIL_REGEXP.match?(value))
      key.failure(:format?)
    end
  end

  rule(:site_contact_phone) do
    key.failure(:missing) if value.blank?
  end

  rule(:site_contact_phone) do
    digits = value.gsub(/\D/, "")
    key.failure(:format?) if value && (!value.match?(VALID_PHONE_NUMBER_REGEX) || digits.length < 10 || digits.length > 13)
  end
end
