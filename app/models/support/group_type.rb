# frozen_string_literal: true

module Support
  #
  # Supported school "establishment types" are grouped
  #
  class GroupType < ApplicationRecord
    has_many :establishment_types, class_name: "Support::EstablishmentType"
    has_many :organisations, through: :establishment_types, class_name: "Support::Organisation"

    validates :name, :code, uniqueness: true
  end
end
