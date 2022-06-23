module Support
  module CollectionHelper
    def procurement_category_grouped_options(selected_category_id: -1)
      category_to_select_option = ->(category) { [category.title, category.id, { selected: selected_category_id == category.id }] }

      Support::Category.top_level.each_with_object([]) do |category, grouped_options|
        sub_categories = category.sub_categories.except_for("No applicable category")

        # Don't show categories with no sub-categories
        next unless sub_categories.any?

        grouped_options << [category.title, sub_categories.map(&category_to_select_option)]
      end
    end

    def non_procurement_query_options(selected_query_id: -1)
      Support::Query.all.map { |q| [q.title, q.id, { selected: selected_query_id == q.id }] }
    end
  end
end
