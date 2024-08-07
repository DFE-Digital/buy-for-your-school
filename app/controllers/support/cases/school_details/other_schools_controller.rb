module Support
  module Cases
    module SchoolDetails
      class OtherSchoolsController < Cases::ApplicationController
        before_action :set_instances, only: %i[confirmation_message remove_school non_beneficiery_schools]

        def non_beneficiery_schools
          @back_url = support_case_path(@current_case, anchor: "school-details")
          @other_schools = @current_case.other_schools.map { |s| Support::OrganisationPresenter.new(s) }
        end

        def other_school
          @other_school_form = OtherSchoolForm.new if @other_school_form.blank?
        end

        def add_other_school
          @organisation = Support::Organisation.find_by(id: other_school_form_params[:school_id])
          @other_school_form = OtherSchoolForm.from_validation(validation)
          if validation.success?
            if (@current_case.other_school_urns.include? @organisation.urn) || (@current_case.organisation.organisations.pluck(:urn).include? @organisation.urn)
              message = if @current_case.other_school_urns.include? @organisation.urn
                          I18n.t("support.case.label.school_details.non_participating_schools.error.already_a_member_message", name: @organisation.name)
                        else
                          I18n.t("support.case.label.school_details.non_participating_schools.error.part_of_group_message", name: @organisation.name)
                        end
              flash[:error] = { message:, class: "govuk-error" }
              render :other_school
            else
              urns = @current_case.other_school_urns << @organisation.urn
              @current_case.update!(other_school_urns: urns)
              redirect_to non_beneficiery_schools_support_case_school_details_other_schools_path(@current_case)
              flash[:notice] = I18n.t("support.case.label.school_details.non_participating_schools.success.message")
            end
          else
            flash[:error] = { class: "remove-message" }
            render :other_school
          end
        end

        def confirmation_message
          @back_url = non_beneficiery_schools_support_case_school_details_other_schools_path(@current_case)
        end

        def remove_school
          school_urns = @current_case.other_school_urns - [@organisation.urn]
          @current_case.update!(other_school_urns: school_urns)
          redirect_to non_beneficiery_schools_support_case_school_details_other_schools_path(@current_case)
        end

      private

        def validation
          OtherSchoolFormSchema.new.call(**other_school_form_params)
        end

        def set_instances
          @organisation = Support::Organisation.find_by(id: params[:school_id])
          @current_case = Support::Case.find_by(id: params[:case_id])
        end

        def other_school_form_params
          params.require(:case_organisation_form).permit(:school_id, :organisation_name)
        end
      end
    end
  end
end
