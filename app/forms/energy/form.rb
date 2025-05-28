#
#  Form object for energy
#
class Energy::Form < Form
  extend Dry::Initializer
  # @return [Hash] form params as request attributes
  def data
    to_h.except(:user, :step, :messages)
  end
end
