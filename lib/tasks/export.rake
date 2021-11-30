desc "Export ActivityLog items"
task export: :environment do
  file = Rails.root.join("public/activity_log.csv")
  data = ActivityLogItem.to_csv

  File.open(file, "w+") { |f| f.write(data) }
end

namespace :support do
  namespace :case_management do
    desc "Export Support Cases"
    task export: :environment do
      file = Rails.root.join("public/support_cases.csv")
      data = Support::Case.to_csv

      File.open(file, "w+") { |f| f.write(data) }
    end
  end

  namespace :activity_log_items do
    desc "Export Support ActivityLog items"
    task export: :environment do
      file = Rails.root.join("public/support_activity_log.csv")
      data = Support::ActivityLogItem.to_csv

      File.open(file, "w+") { |f| f.write(data) }
    end
  end
end
