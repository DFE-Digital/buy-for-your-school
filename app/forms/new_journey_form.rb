# Create a new self-serve journey (specification)
#
# Steps:
#   1: category
#   2: name
#
class NewJourneyForm < Form
  # @!attribute [r] category
  #   @return [String]
  option :category, optional: true

  # @!attribute [r] name
  #   @return [String]
  option :name, optional: true

  # @!attribute [r] user
  #   @return [UserPresenter] decorate respondent
  option :user, ::Types.Constructor(UserPresenter)

  # @!attribute [r] step
  #   @return [Integer]
  option :step, Types::Params::Integer, default: proc { 1 }

  # @return [Hash] form data to be persisted as request attributes
  def data
    to_h
      .except(:user, :step, :category, :messages)
      .compact
      .merge(user_id: user.id, category_id: get_category.id)
  end

  def get_category
    Category.find_by(slug: category)
  end
end
