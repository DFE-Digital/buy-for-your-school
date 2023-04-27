module Support
  module Emails
    module Templates
      class Parser
        def initialize(agent:)
          @agent = agent
        end

        def parse(body)
          Liquid::Template.parse(body, error_mode: :strict).render(build_template_context)
        end

      private

        def build_template_context
          { "caseworker_full_name" => @agent&.full_name }
        end
      end
    end
  end
end
