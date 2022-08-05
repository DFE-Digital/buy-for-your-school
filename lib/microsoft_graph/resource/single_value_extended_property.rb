module MicrosoftGraph
  module Resource
    class SingleValueExtendedProperty
      extend Dry::Initializer

      option :id, Types::String
      option :value, Types::String

      # https://docs.microsoft.com/en-us/office/client-developer/outlook/mapi/pidtaginreplytoid-canonical-property
      ID_PR_IN_REPLY_TO_ID = "String 0x1042".freeze
    end
  end
end
