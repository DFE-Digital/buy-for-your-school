module Support
  class ReviewEvaluationsFormSchema < Schema
    config.messages.top_namespace = :review_evaluations_form

    params do
      optional(:evaluation_approved).value(:array)
    end

    rule :evaluation_approved do
      if value.empty?
        key.failure(:select_at_least_one)
      end
    end
  end
end
