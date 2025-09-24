module Energy
  class MatSchoolPickerForm
    include ActiveModel::Model

    attr_accessor :user, :mat_school_urn

    validates :mat_school_urn, presence: { message: I18n.t("energy.mat_school_picker.errors.must_pick_a_school") }

    def initialize(current_user:)
      @user = current_user
    end

    def data
      { mat_school_urn: }
    end

    def to_h
      data
    end
  end
end
