class Frameworks::ProviderContact::Filtering
  include FilterForm

  initial_scope -> { Frameworks::ProviderContact }

  filter_by :provider, options: -> { Frameworks::Provider.order("short_name ASC").pluck(:short_name, :id) }
end
