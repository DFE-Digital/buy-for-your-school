require "app_schema"

module Support
  module Frameworks
    class Schema < AppSchema
      define do
        required(:name).filled(:string)
        required(:supplier).filled(:string)
        required(:category).filled(:string)
        required(:expires_at).filled(:date)
      end
    end
  end
end
