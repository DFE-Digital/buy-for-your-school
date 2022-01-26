# frozen_string_literal: true

module Support
  class EstablishmentGroupType < ApplicationRecord
    has_many :groups, class_name: "Support::EstablishmentGroup"

    validates :name, :code, uniqueness: true
  end
end
