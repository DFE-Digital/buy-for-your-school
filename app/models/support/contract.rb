# frozen_string_literal: true

module Support
  #
  # Contract between a school and a supplier. Contracts can be New or Existing.
  #
  class Contract < ApplicationRecord
    attribute :duration, :interval

    def self.for(id)
      type = find(id).type
      type.constantize.find(id)
    end

    def to_h
      super.merge(
        duration: duration&.in_months&.to_i,
      )
    end
  end
end
