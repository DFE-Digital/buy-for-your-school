module Support
  module Management
    class AgentForm < ::Support::Agent
      validates :email, :first_name, :last_name, presence: true
      validate :validate_roles_exclusivity

      alias_attribute :__roles, :roles
      attr_writer :roles, :policy

      before_save :assign_roles

    private

      def validate_roles_exclusivity
        new_roles = (@roles || []).reject(&:blank?)
        if (new_roles & %w[cec_admin cec]).any?
          conflicting_roles = new_roles - %w[cec_admin cec]
          if conflicting_roles.any?
            errors.add(:roles, I18n.t("support.management.agents.role_error"))
          end
        end
      end

      def assign_roles
        new_roles = (@roles || []).reject(&:blank?)

        removable = @policy.grantable_role_names & (__roles - new_roles)
        addable = @policy.grantable_role_names & new_roles

        self.__roles = (__roles - removable + addable).uniq
      end
    end
  end
end
