# :nocov:
class FrameworkRequestPresenter < BasePresenter
  # @return [String]
  def school_name
    Support::Organisation.find_by(urn: school_urn)&.name || "n/a"
  end

  # @return [UserPresenter, OpenStruct]
  def user
    if user_id
      UserPresenter.new(super)
    else
      OpenStruct.new(
        email: email,
        first_name: first_name,
        last_name: last_name,
        full_name: "#{first_name} #{last_name}",
      )
    end
  end

  # @return [Boolean]
  def dsi?
    user_id.present?
  end
end
# :nocov:
