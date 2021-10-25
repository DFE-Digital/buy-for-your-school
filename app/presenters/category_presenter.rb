class CategoryPresenter < BasePresenter
  # Downcased title that excludes acronyms
  #
  # @return [String]
  def title_downcase
    title.split.map { |w| /[A-Z]{2,}/.match?(w) ? w : w.downcase }.join(" ")
  end
end
