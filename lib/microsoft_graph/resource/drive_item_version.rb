module MicrosoftGraph
  module Resource
    # https://learn.microsoft.com/en-us/graph/api/resources/driveitemversion?view=graph-rest-1.0
    class DriveItemVersion
      extend Dry::Initializer

      option :id, Types::String
      option :content, optional: true
      option :publication, optional: true
      option :last_modified_by
      option :last_modified_date_time, Types.Instance(DateTime)
      option :size, Types::Integer
    end
  end
end
