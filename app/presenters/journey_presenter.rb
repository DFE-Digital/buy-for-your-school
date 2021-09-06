class JourneyPresenter < SimpleDelegator
  # @return [Array<SectionPresenter>]
  def sections
    @sections ||= super.includes(:tasks).map do |section|
      SectionPresenter.new(section)
    end
  end
end
