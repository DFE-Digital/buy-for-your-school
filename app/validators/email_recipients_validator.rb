class EmailRecipientsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value.map!(&:strip)

    if options[:at_least_one] && Array(value).empty?
      record.errors.add(attribute, options[:at_least_one].try(:[], :message) || "At least one recipient must be specified")
    end

    unless Array(value).all? { |email| URI::MailTo::EMAIL_REGEXP.match?(email) }
      record.errors.add(attribute, options[:message] || "The recipients list contains an invalid email address")
    end
  end
end
