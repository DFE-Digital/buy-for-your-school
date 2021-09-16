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

  # Return the specification in HTML
  #
  # @return [String]
  def specification
    template = LiquidParser.new(
      template: category.liquid_template,
      answers: GetAnswersForSteps.new(visible_steps: steps).call,
    ).render(draft: false)

    DocumentFormatter.new(content: template, to: :html).call.html_safe
  end
end
