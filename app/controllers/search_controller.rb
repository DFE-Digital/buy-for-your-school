class SearchController < Fabs::ApplicationController
  # Keep searches bounded before sending them to Azure AI Search.
  MAX_QUERY_LENGTH = 150
  MAX_WORDS = 25

  def index
    @results = []
    @results_count = 0
    add_breadcrumb_on_rails home_breadcrumb_name, home_breadcrumb_path
    @page_title = "Search results - #{helpers.strip_tags(params[:query])}"
    unless invalid_query?(params[:query])
      query = params[:query].strip
      @results = AzureAiSearch::ContentfulSearcher.new(query:).search
      @results_count = @results.count
    end

    render layout: "search"
  end

private

  def invalid_query?(query)
    if query.blank?
      @validation_error = :empty
      true
    elsif query.length > MAX_QUERY_LENGTH
      @validation_error = :too_long
      true
    elsif query.split(/\s+/).size > MAX_WORDS
      @validation_error = :too_many_words
      true
    else
      false
    end
  end
end
