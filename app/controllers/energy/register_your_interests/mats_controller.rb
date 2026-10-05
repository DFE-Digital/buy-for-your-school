module Energy
  module RegisterYourInterests
    class MatsController < BaseController
      before_action(only: :index) { @registration.step = "mat" }
      before_action(only: :index) { set_back_url(energy_register_your_interest_phone_number_path) }

      def index; end

      def create
        group = Support::EstablishmentGroup.active
          .joins(:establishment_group_type)
          .find_by(uid: registration_params(:mat_uid)[:mat_uid], support_establishment_group_types: { code: Support::EstablishmentGroupType::MAT_CODE })
        attributes = group ? { mat_uid: group.uid, mat_name: group.name, ukprn: group.ukprn } : { mat_uid: nil, mat_name: nil, ukprn: nil }
        save_step("mat", attributes, energy_register_your_interest_gas_path)
      end

      def search
        results = Support::EstablishmentGroup.active
          .joins(:establishment_group_type)
          .where(support_establishment_group_types: { code: Support::EstablishmentGroupType::MAT_CODE })
          .where("support_establishment_groups.name ILIKE :query OR support_establishment_groups.uid ILIKE :query OR support_establishment_groups.ukprn ILIKE :query", query: "%#{params.fetch(:q, '')}%")
          .limit(50)

        render json: results.as_json(only: %i[uid name ukprn], methods: %i[formatted_name])
      end
    end
  end
end
