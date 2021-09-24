class SupportRequestPresenter < BasePresenter
  # return [JourneyPresenter]
  def journey
    JourneyPresenter.new(super)
  end
end
