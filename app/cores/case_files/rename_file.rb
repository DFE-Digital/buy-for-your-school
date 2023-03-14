module CaseFiles
  class RenameFile
    def initialize(attachable)
      @attachable = attachable
    end

    def call(custom_name:, description:)
      @attachable.custom_name = custom_name_with_extension(custom_name)
      @attachable.description = description
      @attachable.save!
    end

    def custom_name_with_extension(custom_name)
      file_extension = ActiveStorage::Filename.new(@attachable.file_name).extension_with_delimiter
      custom_name.gsub(file_extension, "").concat(file_extension)
    end
  end
end
