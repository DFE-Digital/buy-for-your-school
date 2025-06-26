# frozen_string_literal: true

module Energy
  class GenerateSiteAdditionXlDocumentsJob < ApplicationJob
    queue_as :default

    def perform(onboarding_case_id:, current_user_id:)
      onboarding_case = Energy::OnboardingCase.find(onboarding_case_id)
      current_user = User.find(current_user_id)

      Energy::GenerateSiteAdditionXlDocuments.new(onboarding_case:, current_user:).call
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error("GenerateSiteAdditionXlDocumentsJob failed: #{e.message}")
    rescue StandardError => e
      Rails.logger.error("Unhandled error: #{e.message}")
      raise e
    end
  end
end
