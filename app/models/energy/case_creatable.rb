module Energy::CaseCreatable
  extend ActiveSupport::Concern

  def self.create_case(current_user, support_organisation)
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
      kase = Support::CreateCase.new(attrs).call
      Support::CreateInteraction.new(kase.id, "create_case", nil, { body: "DfE Energy support case created", additional_data: attrs.slice(:source, :category).compact }).call
      onboarding_case = Energy::OnboardingCase.create!(are_you_authorised: true, support_case: kase)
      Energy::OnboardingCaseOrganisation.create!(onboarding_case:, onboardable: support_organisation)
    end
  end
end
