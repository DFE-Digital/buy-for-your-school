module Support
  class VirusScanner

    # see https://github.com/kobaltz/clamby/issues/38
    def self.uploaded_file_safe?(uploaded_file)
      file_is_safe = Clamby.safe?(uploaded_file.tempfile.path)

      # # clam daemon cannot access temp folder where uploaded files live so copy it into rails folder
      # temporary_copy = Rails.root.join("tmp/#{uploaded_file.original_filename}")
      # File.open(temporary_copy, "wb") { |file| file.write(uploaded_file.read) }

      # file_is_safe = Clamby.safe?(temporary_copy)

      # File.delete(temporary_copy)

      # File.delete(uploaded_file.tempfile.path) unless file_is_safe

      file_is_safe
    end
  end
end
