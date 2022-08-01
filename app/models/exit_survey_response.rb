class ExitSurveyResponse < ApplicationRecord

  belongs_to :case, class_name: "Support::Case", optional: true

  # Satisfaction rating
  #
  #   very_dissatisfied
  #   dissatisfied
  #   neither - Neither satisfied or dissatisfied
  #   satisfied
  #   very_satisfied
  enum satisfaction_level: { very_dissatisfied: 0, dissatisfied: 1, neither: 2, satisfied: 3, very_satisfied: 4 }, _suffix: true

  # Saved time
  #
  #   strongly_disagree
  #   disagree
  #   neither - Neither agree nor disagree
  #   agree
  #   strongly_agree
  enum saved_time: { strongly_disagree: 0, disagree: 1, neither: 2, agree: 3, strongly_agree: 4 }, _suffix: true

  # Better quality
  #
  #   strongly_disagree
  #   disagree
  #   neither - Neither agree nor disagree
  #   agree
  #   strongly_agree
  enum better_quality: { strongly_disagree: 0, disagree: 1, neither: 2, agree: 3, strongly_agree: 4 }, _suffix: true

  # Future support
  #
  #   strongly_disagree
  #   disagree
  #   neither - Neither agree nor disagree
  #   agree
  #   strongly_agree
  enum future_support: { strongly_disagree: 0, disagree: 1, neither: 2, agree: 3, strongly_agree: 4 }, _suffix: true

  # Hear about the service
  #
  #   dfe_email 
  #   dfe_event
  #   non_dfe_event
  #   dfe_promotion
  #   other_dfe_service_referral
  #   online_search
  #   social_media
  #   word_of_mouth
  #   other
  enum hear_about_service: {  dfe_email: 0, 
                              dfe_event: 1, 
                              non_dfe_event: 2, 
                              dfe_promotion: 3, 
                              other_dfe_service_referral: 4,
                              online_search: 5,
                              social_media: 6,
                              word_of_mouth: 7,
                              other: 8
                            }
end