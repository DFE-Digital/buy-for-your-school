# frozen_string_literal: true

# Abstract base class for all persisted models
#
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.implicit_order_column = "created_at"

  # Used to pass model attributes to forms
  #
  # @return [Hash]
  def to_h
    attributes.symbolize_keys
  end
end
