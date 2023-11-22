module Frameworks::Framework::Evaluatable
  extend ActiveSupport::Concern

  included do
    scope :for_evaluation, -> { by_status(%w[not_approved]) }
  end
end
