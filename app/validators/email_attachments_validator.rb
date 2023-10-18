class EmailAttachmentsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if Array(value).any? { |attachment| incorrect_file_type?(attachment) }
      record.errors.add(attribute, "One or more of the files you uploaded was an incorrect file type")
    end

    if Array(value).any? { |attachment| infected_file?(attachment) }
      record.errors.add(attribute, "One or more of the files you uploaded contained a virus")
    end
  end

private

  def file_resolver
    options[:resolve_with] || ->(attachment) { attachment }
  end

  def infected_file?(attachment)
    !Support::VirusScanner.uploaded_file_safe?(attachment)
  end

  def incorrect_file_type?(attachment)
    !Email::Draft::Attachable.get(attachment).content_type.in?(OUTLOOK_MESSAGE_FILE_TYPE_ALLOW_LIST)
  end
end
