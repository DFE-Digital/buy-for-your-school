class SectionPresenter < SimpleDelegator
  def tasks
    @tasks ||= super.map { |t| TaskPresenter.new(t) }
  end
end
