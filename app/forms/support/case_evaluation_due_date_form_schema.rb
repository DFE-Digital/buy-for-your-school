module Support
  class CaseEvaluationDueDateFormSchema < ::Support::Schema
    config.messages.top_namespace = :case_evaluation_due_date_form

    params do
      required(:evaluation_due_date).value(:hash)
    end

    rule(:evaluation_due_date) do
      key.failure(:missing) if value.values.all?(&:blank?)
    end

    rule :evaluation_due_date do
      key.failure(:invalid) unless value.values.all?(&:blank?) || hash_to_date.call(value)
    end

    rule :evaluation_due_date do
      if value.present?
        date = hash_to_date.call(value)
        if date && date <= Time.zone.today
          key.failure(:must_be_in_the_future)
        end
      end
    end
  end
end
