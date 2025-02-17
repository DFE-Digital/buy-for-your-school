module Support
  class EmailEvaluatorsVariableParser
    include ActionView::Helpers::UrlHelper

    def initialize(current_case, email_evaluators, unique_link = "")
      @current_case = current_case
      @email_evaluators = email_evaluators
      @unique_link = unique_link
    end

    def variables
      {
        "organisation_name" => @current_case.organisation_name || @current_case.email,
        "sub_category" => @current_case.sub_category ? @current_case.sub_category_with_indefinite_article : "a",
        "unique_case_specific_link" => link_to("unique case-specific link", @unique_link, target: "_blank", rel: "noopener noreferrer"),
        "evaluation_due_date" => @current_case.evaluation_due_date.strftime("%d %B %Y"),
      }
    end

    def parse_template
      Liquid::Template.parse(@email_evaluators.body, error_mode: :strict).render(variables)
    end
  end
end
