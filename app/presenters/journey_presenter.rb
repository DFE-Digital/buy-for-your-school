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

  # Parse liquid template through a Markdown parser
  #
  # @return [String]
  def specification
    specification_renderer = SpecificationRenderer.new(
      template: category.liquid_template,
      answers: GetAnswersForSteps.new(visible_steps: steps).call,
    )

    markdown = strip_indentation_spaces(specification_renderer.to_html)
    render_markdown(markdown)
  end

private

  # @param text [String]
  #
  # @return [String]
  def render_markdown(text)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(text).html_safe
  end

  # Removes all spaces that follow a new line (\n)
  #
  # This allows content designers to use indentation in liquid templates
  # to improve readability without those spaces affecting how
  # the markdown is parsed
  #
  # @example "\n  text" -> "\ntext"
  #
  # @param text [String]
  #
  # @return [String]
  def strip_indentation_spaces(text)
    text.gsub(/(?<=\n) */, "")
  end
end
