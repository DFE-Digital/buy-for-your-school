class Frameworks::ProviderContact::Filtering
  include FilterForm

  initial_scope -> { Frameworks::ProviderContact }
  sort_options -> { Frameworks::ProviderContact.available_sort_options }

  filter_by :provider, options: -> { Frameworks::Provider.order("short_name ASC").pluck(:short_name, :id) }
end
