module Support
  class VirusScanner
    def self.uploaded_file_safe?(uploaded_file)
      file_is_safe = ClamavRest.scanner.file_is_safe?(uploaded_file.tempfile)

      File.delete(uploaded_file.tempfile.path) unless file_is_safe

      file_is_safe
    end
  end
end
