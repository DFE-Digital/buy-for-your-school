# Collect user feedback
#
class DownloadSpecificationForm < Form
  # @!attribute [r] choice
  # @return [String]
  option :finished, Types::ConfirmationField | Types::Nil, default: proc { nil }
end
