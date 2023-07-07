module Support
  module Concerns
    module HasCreator
      extend ActiveSupport::Concern

      included do
      end

      def creator
        return unless created_by

        AgentPresenter.new(created_by)
      end
    end
  end
end
