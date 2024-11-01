class Request < ApplicationRecord
  self.abstract_class = true

  # Confidence level
  #
  #   not_applicable
  #   not_at_all_confident
  #   somewhat_confident
  #   slightly_confident
  #   confident
  #   very_confident
  enum :confidence_level, { not_applicable: 0, not_at_all_confident: 1, somewhat_confident: 2, slightly_confident: 3, confident: 4, very_confident: 5 }
end
