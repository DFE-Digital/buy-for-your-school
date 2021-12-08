# frozen_string_literal: true

module Support
  #
  # Contract between a school and a supplier. Contracts can be New or Existing.
  #
  class Contract < ApplicationRecord
    attribute :duration, :interval
  end
end