module Support
  class Messages::Templates
    extend Dry::Initializer

    include MarkdownHelper
    option :params, Types::Hash, optional: false

    def call
      render = Liquid::Template.parse(basic_template, error_mode: :strict).render(basic_template_variables(**params))
      markdown_to_html(render)
    end

    def basic_template
      "{{body}}\n\n"\
      "Regards<br>"\
      "{{agent}}<br>"\
      "Procurement Specialist<br>"\
      "Get help buying for schools"
    end

    def basic_template_variables(body:, agent:)
      {
        "body" => body,
        "agent" => agent,
      }
    end
  end
end
