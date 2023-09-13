class Frameworks::Provider::Filtering
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :scoped_providers, default: -> { Frameworks::Provider }
  attribute :sort_by
  attribute :sort_order

  def results
    providers = scoped_providers

    filters.each { |filter| providers = filter.filter(providers) }

    providers.sorted_by(sort_by:, sort_order:)
  end

  def available_sort_options
    Frameworks::Provider.available_sort_options
  end

  def number_of_selected(field)
    send(field.to_s.singularize).count(&:present?)
  end

private

  def filters
    []
  end
end
