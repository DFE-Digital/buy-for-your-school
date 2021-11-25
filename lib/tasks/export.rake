desc "Export ActivityLog items"
task export: :environment do
  file = Rails.root.join("public/activity_log.csv")
  data = ActivityLogItem.to_csv

  File.open(file, "w+") { |f| f.write(data) }
end
