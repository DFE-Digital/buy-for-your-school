module Support
  class SortCases
    attr_reader :cases

    def initialize(cases) = @cases = cases || Case

    def sort(sorting_params)
      return @cases.order_by_action if sorting_params.blank?

      field, sort_order = sorting_params.first
      sort_order = sort_order == "descending" ? "DESC" : "ASC"
      @cases.public_send("order_by_#{field}", sort_order)
    end
  end
end
