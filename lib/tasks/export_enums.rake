ENUMS_PATH = "db/enums.csv".freeze

namespace :enums do
  desc "Export a list of enums used in the application"
  task export: :environment do
    File.write ENUMS_PATH, enums_to_csv
    warn "Exported to #{ENUMS_PATH}"
  end

  desc "Check whether the current enums list in #{ENUMS_PATH} is up to date"
  task check: :environment do
    if enums_to_csv == File.read(ENUMS_PATH)
      warn "Enums file #{ENUMS_PATH} is up to date"
    else
      abort "Enums file #{ENUMS_PATH} is out of date: run `rake enums:export`"
    end
  end
end

def enums_to_csv
  require "csv"

  Rails.application.eager_load!

  CSV.generate(headers: true) do |csv|
    csv << %w[table column name value]

    ApplicationRecord.descendants.each do |klass|
      next if klass.abstract_class?

      klass.attribute_types.each do |column, attr|
        next unless attr.is_a? ActiveRecord::Enum::EnumType

        attr.send(:mapping).each do |name, value|
          csv << [klass.table_name, column, name, value]
        end
      end
    end
  end
end
