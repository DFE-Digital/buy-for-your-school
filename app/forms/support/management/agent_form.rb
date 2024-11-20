module Support
  module Management
    class AgentForm < ::Support::Agent
      validates :email, :first_name, :last_name, presence: true

      alias_attribute :__roles, :roles
      attr_writer :roles, :policy

      before_save :assign_roles

    private

      def assign_roles
        new_roles = (@roles || []).reject(&:blank?)

        removable = @policy.grantable_role_names & (__roles - new_roles)
        addable = @policy.grantable_role_names & new_roles

        self.__roles = (__roles - removable + addable).uniq
      end
    end
  end
end
