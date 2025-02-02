class Support::Case::DocumentUploader
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :files
  attribute :upload_document_files
  attribute :support_case
  attribute :has_uploaded_documents

  validates :files, presence: true, if: -> { support_case.has_uploaded_documents.nil? }
  validate :files_safe, if: -> { files.present? }
  validates :has_uploaded_documents, presence: true

  def save!
    support_case.upload_document_files(files:)
  end

private

  def files_safe
    results = files.map { |file| Support::VirusScanner.uploaded_file_safe?(file) }
    errors.add(:files, I18n.t("support.case.label.case_files.errors.unsafe")) unless results.all?
  end
end
