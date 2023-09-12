class Frameworks::ProviderContact::Filtering
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :scoped_provider_contacts, default: -> { Frameworks::ProviderContact }
  attribute :provider, default: -> { [] }
  attribute :sort_by
  attribute :sort_order

  def results
    provider_contacts = scoped_provider_contacts

    filters.each { |filter| provider_contacts = filter.filter(provider_contacts) }

    provider_contacts.sorted_by(sort_by:, sort_order:)
  end

  def available_sort_options
    Frameworks::ProviderContact.available_sort_options
  end

  def available_provider_filter_options
    Frameworks::Provider.order("short_name ASC").pluck(:short_name, :id)
  end

  def number_of_selected(field)
    send(field.to_s.singularize).count(&:present?)
  end

private

  def filters
    [
      Support::Concerns::ScopeFilter.new(provider, scope: :by_provider),
    ]
  end
end
