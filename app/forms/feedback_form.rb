# Collect user feedback
#
class FeedbackForm < Form
  # @!attribute [r] user
  #   @return [UserPresenter] decorate respondent
  option :user, ::Types.Constructor(UserPresenter)

  # @!attribute [r] service
  # @return [Symbol]
  option :service, Types::Params::Symbol, default: proc { :create_a_specification }

  # @!attribute [r] satisfaction
  # @return [Symbol]
  option :satisfaction, Types::Params::Symbol, optional: true

  # @!attribute [r] feedback_text
  # @return [String]
  option :feedback_text, optional: true

  # @!attribute [r] full_name
  # @return [String]
  option :full_name, optional: true

  # @!attribute [r] email
  # @return [String]
  option :email, optional: true

  # @return [Hash] form params as request attributes
  def data
    super.except(:user_id).merge(logged_in: !user.guest?, logged_in_as_id: user.id)
  end

  # @return [Array<String>] very_satisfied, satisfied, neither, dissatisfied, very_dissatisfied
  def satisfaction_options
    @satisfaction_options ||= UserFeedback.satisfactions.keys.reverse
  end
end
