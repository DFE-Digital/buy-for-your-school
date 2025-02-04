class Support::Case::DocumentUploader
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :files
  attribute :upload_document_files
  attribute :support_case
  attribute :edit_form

  validates :files, presence: true, if: -> { edit_form == "false" }
  validate :files_safe, if: -> { files.present? }

  def save!
    support_case.upload_document_files(files:)
  end

  def save_evaluation_document!(email)
    support_case.upload_evaluation_document_files(files:, email:)
  end

private

  def files_safe
    results = files.map { |file| Support::VirusScanner.uploaded_file_safe?(file) }
    errors.add(:files, I18n.t("support.case.label.case_files.errors.unsafe")) unless results.all?
  end
end
