module Support
  module CollectionHelper
    def procurement_category_grouped_options(selected_category_id: -1)
      Support::Category.grouped_opts.collect do |parent_name, sub_categories|
        [parent_name, sub_categories.collect do |name, value|
          if name != "No applicable category"
            [name, value, { selected: selected_category_id == value }]
          end
        end.compact]
      end
    end

    def non_procurement_query_options(selected_query_id: -1)
      Support::Query.all.map { |q| [q.title, q.id, { selected: selected_query_id == q.id}] }
    end
  end
end
