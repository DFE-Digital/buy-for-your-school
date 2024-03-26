module Support::EstablishmentSearch::Presentable
  extend ActiveSupport::Concern

  def autocomplete_template
    ApplicationController.render(partial: "support/establishment_search/#{source.underscore}/autocomplete_template", locals: autocomplete_template_vars)
  end

private

  def autocomplete_template_vars
    case source
    when "LocalAuthority" then { name:, establishment_type:, code: }
    else { name:, postcode:, establishment_type:, urn:, ukprn: }
    end
  end
end
