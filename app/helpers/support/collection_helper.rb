module Support
  module CollectionHelper
    def procurement_category_grouped_options(selected_category_id: -1)
      category_to_select_option = ->(category) { [category_name(category), category.id, { selected: selected_category_id == category.id }] }

      Support::Category.top_level.ordered_by_title.each_with_object([]) do |category, grouped_options|
        sub_categories = category.sub_categories.except_for("No applicable category").to_a

        # Remove archived categories but leave one if it is already selected
        sub_categories.filter! { |sub_category| !sub_category.archived? || sub_category.id == selected_category_id }

        # Don't show categories with no sub-categories
        next unless sub_categories.any?

        grouped_options << [category_name(category), sub_categories.map(&category_to_select_option)]
      end
    end

    def non_procurement_query_options(selected_query_id: -1)
      Support::Query.all.map { |q| [q.title, q.id, { selected: selected_query_id == q.id }] }
    end

    def category_name(category)
      if category.archived?
        "(archived) #{category.title}"
      else
        category.title
      end
    end

    def procurement_stage_grouped_options(selected_procurement_stage_id: -1, energy_case: false, energy_case_submitted: false)
      (energy_case && energy_case_submitted ? [6] : Support::ProcurementStage.stages).map do |stage|
        ["STAGE #{stage}", Support::ProcurementStage.substages_for_stage(stage).map { |sub_stage| [sub_stage.title, sub_stage.id, { selected: selected_procurement_stage_id == sub_stage.id }] }]
      end
    end
  end
end
