# BusinessTime::Config.load("#{Rails.root}/config/business_time.yml")

BusinessTime::Config.beginning_of_workday = "9:00 am"
BusinessTime::Config.end_of_workday = "17:30 pm"

Holidays.cache_between(Time.zone.now, 2.years.from_now, :gb_eng, :observed)

Holidays.between(Time.zone.now, 2.years.from_now, :gb_eng, :observed).map do |holiday|
  BusinessTime::Config.holidays << holiday[:date]
end
