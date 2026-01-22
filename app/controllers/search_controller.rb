class SearchController < ApplicationController
  skip_before_action :authenticate_user!
  # These are the limits for the Contentful search API
  MAX_QUERY_LENGTH = 150
  MAX_WORDS = 25

  before_action :disable_search_in_header

  def index
    @solutions = []
    @categories = []
    @results_count = 0
    add_breadcrumb home_breadcrumb_name, home_breadcrumb_path
    @page_title = "Search results - #{helpers.strip_tags(params[:query])}"
    unless invalid_query?(params[:query])
      query = params[:query].strip
      @solutions = Solution.search(query: query)
      @categories = FABS::Category.search(query: query)
      @results_count = @solutions.count + @categories.count
    end
    
    render layout: "fabs_application"
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
end
