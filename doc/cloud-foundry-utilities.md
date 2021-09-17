# Cloud Foundry Utilities

## Prerequisites

You must already have Cloud Foundry installed, user account setup and be able to access the [console](file.console-access.html).

## Exporting Data to CSV

1. From a local terminal login to Cloud Foundry and SSH into the specified application.
   ```
   $ cf ssh REDACTED-APP-NAME-PROD
   ```
1. Enter app directory
   ```
   $ cd /srv/app/
   ```
1. Access rails console and paste your script (as per example provided in step 2, modified)
   ```
   $ PATH=$PATH:/usr/local/bundle/bin:/usr/local/bin rails console
   ```
1. Example code to dump to CSV file.

   ```ruby
   require 'csv'
   file = "#{Rails.root}/public/example_data.csv"
   records = YOUR-MODEL.order(:created_at)
   csv_headers = ["id", "attr_1", "attr_2"]
   CSV.open(file, 'w', write_headers: true, headers: csv_headers) do |writer|
       records.each do |record|
       writer << [record.id, record.attr_1, record_attr_2]
     end
   end
   ```