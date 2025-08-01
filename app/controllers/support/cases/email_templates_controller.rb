module Support
  module Cases
    class EmailTemplatesController < Cases::ApplicationController
      require "will_paginate/array"
      include CecEmailTemplateFilters

      before_action :back_url, only: %i[index]

      def index
        parser = Email::TemplateParser.new
        @filter_form = Support::Management::EmailTemplateFilterForm.new(**filter_params)
        @templates = @filter_form.results.map { |e| Support::EmailTemplatePresenter.new(e, parser) }.paginate(page: params[:page])
      end

    private

      def form_params
        params.require(:email_template_form).permit(*%i[
          group_id subgroup_id stage title description subject body
        ]).merge(id: params[:id], agent: current_agent)
      end

      def back_url
        @back_url ||= url_from(back_link_param) || support_cases_path
      end
    end
  end
end
