# frozen_string_literal: true

# @param headings An array of strings
# @param rows An array of arrays of values
class TableComponent < ViewComponent::Base
  def initialize(headings:, rows:)
    @headings = headings
    @rows = rows
  end
end
