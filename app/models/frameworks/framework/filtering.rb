class Frameworks::Framework::Filtering
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :scoped_frameworks, default: -> { Frameworks::Framework }
  attribute :status, default: -> { [] }
  attribute :provider, default: -> { [] }
  attribute :e_and_o_lead, default: -> { [] }
  attribute :proc_ops_lead, default: -> { [] }
  attribute :category, default: -> { [] }
  attribute :provider_contact, default: -> { [] }
  attribute :sort_by
  attribute :sort_order

  def results
    frameworks = scoped_frameworks

    filters.each { |filter| frameworks = filter.filter(frameworks) }

    frameworks.sorted_by(sort_by:, sort_order:)
  end

  def available_category_options
    Support::Category.order("title ASC").where(id: Frameworks::FrameworkCategory.pluck(:support_category_id)).pluck(:title, :id)
  end

  def available_provider_filter_options
    Frameworks::Provider.order("short_name ASC").pluck(:short_name, :id)
  end

  def available_e_and_o_lead_options
    Support::Agent.by_first_name.where(id: Frameworks::Framework.pluck(:e_and_o_lead_id))
      .map { |agent| [agent.full_name, agent.id] }
  end

  def available_proc_ops_lead_options
    Support::Agent.by_first_name.where(id: Frameworks::Framework.pluck(:proc_ops_lead_id))
      .map { |agent| [agent.full_name, agent.id] }
  end

  def available_status_filter_options
    Frameworks::Framework.statuses.map { |label, _id| [label.humanize, label] }
  end

  def available_provider_contact_options
    Frameworks::ProviderContact.sort_by_name("ascending").pluck(:name, :id)
  end

  def available_sort_options
    Frameworks::Framework.available_sort_options
  end

  def number_of_selected(field)
    send(field.to_s.singularize).count(&:present?)
  end

private

  def filters
    [
      Support::Concerns::ScopeFilter.new(status, scope: :by_status),
      Support::Concerns::ScopeFilter.new(provider, scope: :by_provider),
      Support::Concerns::ScopeFilter.new(e_and_o_lead, scope: :by_e_and_o_lead),
      Support::Concerns::ScopeFilter.new(proc_ops_lead, scope: :by_proc_ops_lead),
      Support::Concerns::ScopeFilter.new(category, scope: :by_category),
      Support::Concerns::ScopeFilter.new(provider_contact, scope: :by_provider_contact),
    ]
  end
end
