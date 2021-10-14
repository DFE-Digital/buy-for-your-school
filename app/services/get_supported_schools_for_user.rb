class GetSupportedSchoolsForUser
  attr_reader :user

  class School
    extend Dry::Initializer

    option :name
    option :urn
    option :type

    def supported?
      type["id"].present? && type["id"].to_i.in?(ORG_TYPE_IDS)
    end
  end

  def initialize(user:)
    @user = user
  end

  def call
    Array(user.orgs)
      .map { |orginisation|
        begin
          School.new(**orginisation.symbolize_keys)
        rescue KeyError
          nil
        end
      }
      .compact
      .select(&:supported?)
  end
end
