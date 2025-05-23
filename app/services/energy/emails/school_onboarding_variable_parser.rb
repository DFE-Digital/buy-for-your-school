module Energy
  class Emails::SchoolOnboardingVariableParser
    include ActionView::Helpers::UrlHelper

    def initialize(current_case, email_evaluators, unique_link = "")
      @current_case = current_case
      @email_evaluators = email_evaluators
      @unique_link = unique_link
    end

    def variables
      {
        "case_creator_full_name" => "#{@current_case.first_name} #{@current_case.last_name}".strip,
        "case_reference_number" => @current_case.ref,
        "organisation_name" => @current_case.organisation_name || @current_case.email,
        "unique_case_specific_link" => link_to("link", @unique_link, target: "_blank", rel: "noopener noreferrer"),
      }
    end

    def parse_template
      Liquid::Template.parse(@email_evaluators.body, error_mode: :strict).render(variables)
    end
  end
end
