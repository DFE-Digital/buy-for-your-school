module Frameworks::Framework::Evaluatable
  extend ActiveSupport::Concern

  included do
    scope :for_evaluation, -> { by_status(%w[pending_evaluation not_approved]) }
  end
end
