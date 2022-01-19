class FafPresenter < BasePresenter
  # @return [String]
  def full_name
    "#{first_name} #{last_name}"
  end

  # @return [String]
  def school_name
    Support::Organisation.find_by(urn: school_urn)&.name || "n/a"
  end
end
