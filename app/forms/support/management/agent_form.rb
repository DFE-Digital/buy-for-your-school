module Support
  module Management
    class AgentForm
      include ActiveModel::Model

      validates :email, presence: true
      validates :first_name, presence: true
      validates :last_name, presence: true

      attr_accessor(
        :email,
        :first_name,
        :last_name,
        :roles,
      )

      def self.from_agent(agent)
        new(
          email: agent.email,
          first_name: agent.first_name,
          last_name: agent.last_name,
          roles: agent.roles,
        )
      end
    end
  end
end
