class CaseRequest::SameSupplierer
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :case_request
  attribute :same_supplier_used

  validates :same_supplier_used, presence: true

  def save!
    case_request.choose_same_supplier(same_supplier_used)
  end
end
