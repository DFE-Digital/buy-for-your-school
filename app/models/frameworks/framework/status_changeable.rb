module Frameworks::Framework::StatusChangeable
  extend ActiveSupport::Concern

  included do
    enum status: {
      pending_evaluation: 0,
      not_approved: 1,
      dfe_approved: 2,
      cab_approved: 3,
    }
  end
end
