class Frameworks::Provider::Filtering
  include FilterForm

  initial_scope -> { Frameworks::Provider }
  sort_options -> { Frameworks::Provider.available_sort_options }
end
