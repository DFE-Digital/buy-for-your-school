# frozen_string_literal: true

module Support
  #
  # A case can be opened on behalf of a Specify user affiliated to a supported
  # organisation which is affirmed by data from DSI.
  #
  # The classname has been chosen to reflect the data source.
  #
  # The definition of an "Organisation" is currently a physical school with an address.
  #
  # The classname/definition may change to "Establishment" or an additional one
  # may be required to accurately model the structure.
  #
  class Organisation < ApplicationRecord
    belongs_to :establishment_type,
               counter_cache: true,
               class_name: "Support::EstablishmentType"

    validates :urn, uniqueness: true
    validates :name, presence: true

    enum phase: {
      no_phase: 0,
      nursery: 1,
      primary: 2,
      middle_primary: 3,
      secondary: 4,
      middle_secondary: 5,
      sixteen_plus: 6,
      all_through: 7,
    }

    enum gender: {
      no_gender: 0,
      boys: 1,
      girls: 2,
      mixed: 3,
      no_recorded_gender: 9,
    }

    enum status: {
      open: 1,
      closed: 2,
      closing: 3,
      opening: 4,
    }
  end
end
