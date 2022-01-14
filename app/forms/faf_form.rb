# @abstract Form Object for multi-step Find-a-Framework support questionnaire
#
class FafForm < Form
  # @!attribute [r] dsi
  # @return [Boolean]
  option :dsi, Types::Params::Bool, optional: true # 1
end
