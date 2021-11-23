namespace :support do
  namespace :cases do
    desc "Export Support ActivityLog items"
    task export: :environment do
      file = Rails.root.join("public/support_cases.csv")
      data = Support::Case.to_csv

      File.open(file, "w+") { |f| f.write(data) }
    end
  end
end
