module Support::Case::Transferable
  extend ActiveSupport::Concern

  def transferrer(params = {})
    Support::Case::Transferrer.new(support_case: self, **params)
  end

  def transfer_to_framework_evaluation(framework_id:, assignee_id:)
    transaction do
      evaluation = Frameworks::Evaluation.transfer_from_support_case(self, framework_id, assignee_id)
      close_case
      record_transfer(destination_id: evaluation.id, destination_type: evaluation.class.name)
      evaluation
    end
  end

private

  def close_case(reason: "Evaluation case")
    Support::ChangeCaseState.new(
      kase: self,
      agent: Current.actor,
      to: :close,
      reason: :transfer,
      info: ". Reason given: #{reason}",
    ).call
    Support::RecordAction.new(case_id: id, action: "close_case", data: { closure_reason: reason }).call
  end

  def record_transfer(destination_id:, destination_type:)
    interactions.case_transferred.create!(
      body: "Transferred to framework evaluation",
      agent_id: Current.actor.id,
      additional_data: { destination_id:, destination_type: },
    )
    Support::RecordAction.new(case_id: id, action: "transfer_case", data: { destination_id:, destination_type: }).call
  end
end
