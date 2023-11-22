class Frameworks::Evaluation::Filtering
  include FilterForm

  initial_scope -> { Frameworks::Evaluation }

  filter_by :status, options: -> { Frameworks::Evaluation.statuses.map { |label, _id| [label.humanize, label] } }
  filter_by :provider, options: -> { Frameworks::Provider.order("short_name ASC").pluck(:short_name, :id) }
  filter_by :assignee, options: -> { Support::Agent.where(id: Frameworks::Evaluation.pluck(:assignee_id)).order("first_name, last_name ASC").map { |agent| [agent.full_name, agent.id] } }
  filter_by :category, options: -> { Support::Category.where(id: Frameworks::FrameworkCategory.pluck(:support_category_id)).pluck(:title, :id) }
end
