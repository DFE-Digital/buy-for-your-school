class RevertFormSubmittedAtToCase6299 < ActiveRecord::Migration[7.2]
  def up
    update_support_case
  end

  def down; end

private

  def update_support_case
    return if support_case.nil?

    onboarding_case = support_case.energy_onboarding_case
    return if onboarding_case.nil?

    onboarding_case.update!(form_submitted_email_sent: false, submitted_at: nil)
  end

  def support_case
    Support::Case.find_by(ref: case_ref)
  end

  def case_ref
    if ENV["APPLICATION_URL"]&.include? "dev"
      "001087"
    elsif ENV["APPLICATION_URL"]&.include? "staging"
      "000839"
    else
      "006299"
    end
  end
end
