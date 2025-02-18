module FilterForm
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Attributes

    attribute :sort_by
    attribute :sort_order
  end

  def results
    records = scoped_records
    filters.each { |filter| records = filter.filter(records) }
    records.sorted_by(sort_by:, sort_order:)
  end

  def number_of_selected(field)
    send(field.to_s.singularize).count(&:present?)
  end

private

  def filters
    self.class.filter_attributes.map do |attr, options|
      Support::Concerns::ScopeFilter.new(send(attr), **options)
    end
  end

  class_methods do
    def initial_scope(proc)
      define_method :scoped_records do
        proc.call
      end

      define_method :available_sort_options do
        proc.call.available_sort_options
      end
    end

    def sort_options(proc)
      define_method :available_sort_options do
        proc.call
      end
    end

    def filter_by(name, default: -> { [] }, multiple: true, options: -> { [] }, scope: nil)
      attribute(name, default:)

      filter_attributes[name] = { scope: scope.presence || "by_#{name}", multiple: }

      define_method "available_#{name}_options" do
        options.call
      end
    end

    def filter_attributes
      @filter_attributes ||= {}
    end
  end
end
