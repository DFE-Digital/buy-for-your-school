# Provide formatted versions of support request fields for views
#
class SupportRequestPresenter < SimpleDelegator
  # @return [String] the name of the school
  def school_name
    user.supported_schools.find { |school| school.urn == school_urn }&.name
  end

  # return [JourneyPresenter, nil]
  def journey
    JourneyPresenter.new(super) if super.present?
  end

private

  def user
    UserPresenter.new(super)
  end
end
