class SupportRequestPresenter < BasePresenter
  # return [JourneyPresenter, nil]
  def journey
    JourneyPresenter.new(super) if super.present?
  end
end
