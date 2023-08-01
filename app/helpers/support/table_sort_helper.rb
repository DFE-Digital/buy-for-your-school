module Support
  module TableSortHelper
    def sortable_th(param, title, scope, form, sort_config: :asc_desc, th_classes: nil, th_attributes: nil)
      sort = form.sort_order if form.sort_by == param.to_s
      render "support/helpers/sortable_th", param:, title:, scope:, sort:, sort_config:, th_classes:, th_attributes:
    end
  end
end
