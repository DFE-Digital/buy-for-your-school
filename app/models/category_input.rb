class CategoryInput
  include ActiveModel::Validations
  include ActiveModel::AttributeAssignment

  attr_accessor :category_id

  validates :category_id, presence: true
end