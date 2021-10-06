class UserPresenter < SimpleDelegator
  def active_journeys
    journeys.initial.map { |j| JourneyPresenter.new(j) }
  end

  def full_name
    super || "#{first_name} #{last_name}"
  end
end
