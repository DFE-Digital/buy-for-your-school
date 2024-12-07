module Support
  class CaseEvaluationDueDateForm < Form
    option :evaluation_due_date, Types::DateField, optional: true
  end
end
