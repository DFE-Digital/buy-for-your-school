# @abstract Form Object for multi-step Find-a-Framework support questionnaire
#
class FafForm < BaseForm
  # @!attribute [r] step
  # @return [Integer] internal counter defaults to 1, coerces strings
  option :step, Types::Params::Integer, default: proc { 1 }

  # @!attribute [r] dsi
  # @return [Boolean]
  option :dsi, Types::Params::Bool, optional: true # 1

  # Proceed or skip to next questions
  #
  # @param num [Integer] number of steps to advance
  #
  # @return [Integer] next step position
  def advance!(num = 1)
    @step += num
  end

  # @return [Integer] previous step position
  def back
    @step - 1
  end

  # @see SupportRequestsController#update
  #
  # @return [Hash] form parms as support request attributes
  def to_h
    self.class.dry_initializer.attributes(self).except(:step, :messages)
  end
end
