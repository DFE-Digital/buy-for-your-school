class Frameworks::Framework::Filtering
  include FilterForm

  get_agents = ->(type_id) { Support::Agent.by_first_name.where(id: Frameworks::Framework.pluck(type_id)) }

  initial_scope -> { Frameworks::Framework }

  filter_by :status,           options: -> { Frameworks::Framework.statuses.map { |label, _id| [label.humanize, label] } }
  filter_by :provider,         options: -> { Frameworks::Provider.order("short_name ASC").pluck(:short_name, :id) }
  filter_by :e_and_o_lead,     options: -> { get_agents[:e_and_o_lead_id].map { |agent| [agent.full_name, agent.id] } }
  filter_by :proc_ops_lead,    options: -> { get_agents[:proc_ops_lead_id].map { |agent| [agent.full_name, agent.id] } }
  filter_by :category,         options: -> { Support::Category.order("title ASC").where(id: Frameworks::FrameworkCategory.pluck(:support_category_id)).pluck(:title, :id) }
  filter_by :provider_contact, options: -> { Frameworks::ProviderContact.sort_by_name("ascending").pluck(:name, :id) }
  filter_by :omnisearch, multiple: false
end
