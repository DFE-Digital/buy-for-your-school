module Support
  class CaseAssignmentFormSchema < Dry::Validation::Contract
    include Concerns::TranslatableFormSchema

    params do
      required(:agent_id).value(:string)
    end

    rule(:agent_id) do
      key(:agent_id).failure(:missing) if value.blank?
    end
  end
end
