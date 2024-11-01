class UserJourney < ApplicationRecord
  belongs_to :case, class_name: "Support::Case", optional: true
  belongs_to :framework_request, class_name: "FrameworkRequest", optional: true
  has_many :user_journey_steps, class_name: "UserJourneyStep"

  enum :status, { in_progress: 0, complete: 1, case_created: 2 }

  def self.find_or_create_new_in_progress_by(criteria = {})
    find_by!(criteria)
  rescue ActiveRecord::RecordNotFound
    in_progress.create!(criteria.except(:id))
  end

  def record_step(product_section:, step_description:)
    user_journey_steps.create(product_section:, step_description:)
  end
end
