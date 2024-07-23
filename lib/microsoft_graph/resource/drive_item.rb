module MicrosoftGraph
  module Resource
    # https://learn.microsoft.com/en-us/graph/api/resources/driveitem?view=graph-rest-1.0
    class DriveItem
      extend Dry::Initializer

      option :id, Types::String
      option :name, Types::String
      option :last_modified_by
      option :last_modified_date_time, Types.Instance(DateTime)
      option :web_url, Types::String
    end
  end
end
