module Support::Case::Surveyable
  extend ActiveSupport::Concern

  def agent_for_satisfaction_survey
    return agent.full_name if agent.present?

    resolved_interaction = interactions.state_change.where("body LIKE '%to resolved%'").order(created_at: :desc).first
    return resolved_interaction.agent.full_name if resolved_interaction.present? && resolved_interaction.agent.present?

    "Get help buying for schools"
  end
end
