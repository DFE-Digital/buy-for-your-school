module FrameworkRequests
  class ConfirmSignInForm < BaseForm
    def initialize(attributes = {})
      super
      @first_name = @user.first_name
      @last_name = @user.last_name
      @email = @user.email
      assign_organisation if @user.single_org?
    end

    def assign_organisation
      organisation_type = @user.school_urn ? Support::Organisation : Support::EstablishmentGroup
      gias_id = @user.school_urn || @user.group_uid

      @organisation = organisation_type.find_by_gias_id(gias_id)
      @group = @user.group_uid.present?
    end

    def data
      super.merge(user: @user.__getobj__)
    end
  end
end
