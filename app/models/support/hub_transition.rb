# frozen_string_literal: true

module Support
  #
  # A hub transition is the supporting object ProcOps use when opening/copying a case manually from existing CRMs
  #
  class HubTransition < ApplicationRecord
    belongs_to :case, class_name: "Support::Case"
  end
end
