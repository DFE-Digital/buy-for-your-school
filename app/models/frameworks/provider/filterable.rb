module Frameworks::Provider::Filterable
  extend ActiveSupport::Concern

  class_methods do
    def filtering(params = {})
      Frameworks::Provider::Filtering.new(params)
    end
  end
end
