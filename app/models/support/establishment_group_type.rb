# frozen_string_literal: true

module Support
  class EstablishmentGroupType < ApplicationRecord
    FEDERATION_CODE = 1
    TRUST_CODE = 2
    MAT_CODE = 6
    SAT_CODE = 10

    has_many :groups, class_name: "Support::EstablishmentGroup"

    validates :name, :code, uniqueness: true

    def federation? = code == FEDERATION_CODE

    def trust? = code == TRUST_CODE

    def mat? = code == MAT_CODE

    def sat? = code == SAT_CODE
  end
end
