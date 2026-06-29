class SearchController < Fabs::ApplicationController
  # These are the limits for the Contentful search API
  MAX_QUERY_LENGTH = 150
  MAX_WORDS = 25

  before_action :disable_search_in_header

  def index
    @solutions = []
    @categories = []
    @results_count = 0
    add_breadcrumb_on_rails home_breadcrumb_name, home_breadcrumb_path
    @page_title = "Search results - #{helpers.strip_tags(params[:query])}"
    unless invalid_query?(params[:query])
      query = params[:query].strip
      @solutions = Solution.search(query:)
      @categories = FABS::Category.search(query:)
      @results_count = @solutions.count + @categories.count
      build_search_comparison(query) if compare_search?
    end

    render layout: "search"
  rescue Contentful::BadRequest
    @validation_error = :contentful_error
  end

private

  def disable_search_in_header
    @show_search_in_header = false
  end

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

  def compare_search?
    ActiveModel::Type::Boolean.new.cast(params[:compare_search])
  end

  def build_search_comparison(query)
    @search_comparison_enabled = true
    @opensearch_solutions = comparison_results("OpenSearch") { SolutionSearcher.new(query:).search }
    @azure_solutions = comparison_results("Azure AI Search") { AzureAiSearch::SolutionSearcher.new(query:).search }
  end

  def comparison_results(label)
    yield
  rescue StandardError => e
    Rollbar.warning("#{label} comparison search failed", error: e.message) if defined?(Rollbar)
    @comparison_errors ||= {}
    @comparison_errors[label] = e.message
    []
  end
end
