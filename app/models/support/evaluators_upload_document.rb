module Support
  class EvaluatorsUploadDocument < ApplicationRecord
    belongs_to :case, class_name: "Support::Case", foreign_key: :support_case_id
    belongs_to :attachable, polymorphic: true, optional: true
    delegate :file, :file_type, to: :attachable
  end
end
