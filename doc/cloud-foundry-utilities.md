# Cloud Foundry Utilities

The purpose of this file is to document ways to perform various tasks (data export etc) within the application(s) running within Cloud Foundry.

## Prerequisites

You must already have Cloud Foundry installed, user account setup and be able to access the console.

[You can read more about this here.](console-access.md).

## Exporting Data to CSV

1. From a local terminal login to Cloud Foundry and SSH into the specified application.
    ```
    $ cf ssh REDACTED-APP-NAME-PROD
    ```
2. Example dump to CSV file.
    ```
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
3. Access rails console and paste your script (as above, modified)
   ```
   cd /srv/app/ then PATH=$PATH:/usr/local/bundle/bin:/usr/local/bin rails console
   ```
4. The CSV file will be available from the public directory, it's recommended that you delete the file after your have downloaded it.
   ```
   rm example_data.csv
   ```
