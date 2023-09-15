class Frameworks::Provider::Filtering
  include FilterForm

  initial_scope -> { Frameworks::Provider }
end
