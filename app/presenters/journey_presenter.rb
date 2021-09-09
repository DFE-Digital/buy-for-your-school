class JourneyPresenter < SimpleDelegator
  # @return [Array<SectionPresenter>]
  def sections
    @sections ||= sections_with_tasks.map do |section|
      SectionPresenter.new(section)
    end
  end

  # @return [Array<StepPresenter>]
  def steps
    super.visible.map { |s| StepPresenter.new(s) }
  end

  # @return [String]
  def created_at
    super.strftime("%e %B %Y")
  end
end
