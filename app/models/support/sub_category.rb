module Support
  #
  # Specific type of procurement a case is tackling
  #
  class SubCategory < ApplicationRecord
    belongs_to :category,
               class_name: "Support::Category"
    # foreign_key: :category_id

    # TODO: validate all fields in code and at DB layer
    validates :title, presence: true
    # validates :description, presence: true
    # validates :slug, presence: true
  end
end
