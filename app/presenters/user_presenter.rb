class UserPresenter < SimpleDelegator
  # @return [Array<JourneyPresenter>]
  def active_journeys
    journeys.initial.map { |j| JourneyPresenter.new(j) }
  end

  # @return [String]
  def full_name
    super || "#{first_name} #{last_name}"
  end
end
