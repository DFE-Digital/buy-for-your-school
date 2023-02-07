class JourneyPresenter < BasePresenter
  delegate :slug, to: :category, prefix: :category

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

  def description
    category.title
  end

  # Return the specification in HTML
  #
  # @return [String]
  def specification
    SpecificationRenderer.new(journey: self, to: :html).call(draft: false).html_safe
  end

  # @return [CategoryPresenter]
  def category
    CategoryPresenter.new(super)
  end

  def status
    return I18n.t("journey.state.in_progress") unless finished?

    I18n.t("journey.state.finished")
  end
end
