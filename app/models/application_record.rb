# frozen_string_literal: true

# Abstract base class for all persisted models
#
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.implicit_order_column = "created_at"
end
