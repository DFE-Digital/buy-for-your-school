# frozen_string_literal: true

module Support
  #
  # Supported schools must be of a particular "establishment type"
  #
  class EstablishmentType < ApplicationRecord
    belongs_to :group, counter_cache: true, class_name: "Support::Group"
    has_many :organisations, class_name: "Support::Organisation"

    validates :name, :code, uniqueness: true
  end
end
