class Frameworks::Evaluation::Filtering
  include FilterForm

  initial_scope -> { Frameworks::Evaluation }

  filter_by :status, options: -> { Frameworks::Evaluation.statuses.map { |label, _id| [label.humanize, label] } }
end
