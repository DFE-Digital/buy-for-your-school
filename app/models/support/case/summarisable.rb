module Support::Case::Summarisable
  extend ActiveSupport::Concern

  def summary(params = summary_defaults)
    Support::Case::Summary.new(support_case: self, **params)
  end

  def summarise(params)
    update!(params)
  end

private

  def summary_defaults
    {
      request_type: category.present?,
      category_id:,
      other_category:,
      query_id:,
      other_query:,
      request_text:,
      support_level:,
      procurement_stage_id:,
      value:,
      source:,
      project:,
      next_key_date:,
      next_key_date_description:,
    }
  end
end
