module Support
  module TableSortHelper
    def sortable_th(param, title, scope, form, sort_order: :asc_desc, th_classes: nil, th_attributes: nil)
      sort = form.sort&.dig(param.to_s)
      render "support/helpers/sortable_th", param:, title:, scope:, sort:, sort_order:, th_classes:, th_attributes:
    end
  end
end
