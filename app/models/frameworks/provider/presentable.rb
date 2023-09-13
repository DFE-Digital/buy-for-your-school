module Frameworks::Provider::Presentable
  extend ActiveSupport::Concern

  def display_name
    name.presence || short_name
  end
end
