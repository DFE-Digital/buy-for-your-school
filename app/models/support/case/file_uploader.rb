class Support::Case::FileUploader
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :support_case
  attribute :files

  validates :support_case, presence: true
  validates :files, presence: true
  validate :files_safe, if: -> { files.present? }

  def save!
    support_case.upload_files(files:)
  end

private

  def files_safe
    results = files.map { |file| Support::VirusScanner.uploaded_file_safe?(file) }
    errors.add(:files, I18n.t("support.case.label.case_files.errors.unsafe")) unless results.all?
  end
end
