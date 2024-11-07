module Support::EstablishmentSearch::Presentable
  extend ActiveSupport::Concern

  def autocomplete_template
    ApplicationController.render(partial: "support/establishment_search/#{source.underscore}/autocomplete_template", locals: autocomplete_template_vars)
  end

private

  def autocomplete_template_vars
    case source
    when "LocalAuthority" then { name:, establishment_type:, code: }
    else { name:, postcode:, establishment_type:, proposed_open_or_closed:, urn:, ukprn: }
    end
  end

  def proposed_open_or_closed
    case organisation_status
    when "opening"
      I18n.t(organisation_status, scope: "support.organisation_statuses", date: I18n.l(opened_date, format: :compact))
    when "closing"
      I18n.t(organisation_status, scope: "support.organisation_statuses", date: I18n.l(closed_date, format: :compact))
    else ""
    end
  end
end
