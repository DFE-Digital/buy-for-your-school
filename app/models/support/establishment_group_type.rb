# frozen_string_literal: true

module Support
  class EstablishmentGroupType < ApplicationRecord
    has_many :groups, class_name: "Support::EstablishmentGroup"

    validates :name, :code, uniqueness: true

    def federation? = code == 1

    def trust? = code == 2

    def mat? = code == 6

    def sat? = code == 10
  end
end
