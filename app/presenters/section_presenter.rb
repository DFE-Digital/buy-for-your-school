class SectionPresenter < BasePresenter
  # @return [Array<TaskPresenter>]
  def tasks
    @tasks ||= super.map { |t| TaskPresenter.new(t) }
  end
end
