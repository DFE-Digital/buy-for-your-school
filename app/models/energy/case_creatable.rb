module Energy::CaseCreatable
  extend ActiveSupport::Concern

  # If we're creating a case for a MAT, there'll be no organisations at this stage
  def self.create_case(current_user, support_organisation = nil)
    ActiveRecord::Base.transaction do
      attrs = {
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        email: current_user.email,
        source: :energy_onboarding,
        support_level: :L7,
        category_id: Support::Category.find_by(title: "DfE Energy for Schools service").id,
        organisation: support_organisation,
        state: :on_hold,
        procurement_stage: Support::ProcurementStage.find_by(key: "onboarding_form"),
      }
      support_case = Support::CreateCase.new(attrs).call
      Support::CreateInteraction.new(support_case.id, "create_case", nil, { body: "DfE Energy support case created", additional_data: attrs.slice(:source, :category).compact }).call
      onboarding_case = Energy::OnboardingCase.create!(are_you_authorised: true, support_case:)
      Energy::OnboardingCaseOrganisation.create!(onboarding_case:, onboardable: support_organisation) if support_organisation
      [support_case, onboarding_case]
    end
  end
end
