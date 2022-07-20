class CreateExitSurveyResponse
  extend Dry::Initializer

  # @!attribute case_id
  # @return [String]
  option :case_id, Types::String

  # @!attribute case_ref
  # @return [String]
  option :case_ref, Types::String

  # @return ExitSurveyResponse
  def call
    e = ExitSurveyResponse.create!(
      case_id: @case_id,
      case_ref: @case_ref
    )
  end
end