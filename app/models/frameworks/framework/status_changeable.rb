module Frameworks::Framework::StatusChangeable
  extend ActiveSupport::Concern

  included do
    enum status: {
      pending_evaluation: 0,
      evaluating: 1,
      not_approved: 2,
      dfe_approved: 3,
      cab_approved: 4,
    }
  end
end
