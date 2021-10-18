# frozen_string_literal: true

module Support
  #
  # Documents such as specification that can be attached to a case.
  #
  class Document < ApplicationRecord
    belongs_to :case, class_name: "Support::Case"
  end
end
