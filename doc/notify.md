# Notify

Gov.uk Notification Service

- [Service settings](https://www.notifications.service.gov.uk/services/73c59fe6-a823-49b9-888b-f3960c33b11c)
- [Documentation](https://docs.notifications.service.gov.uk/ruby.html)

## Monthly gas price update emails

The `energy:send_gas_price_updates` rake task sends one email per school in a pricing JSON file. It selects the single-meter or multi-meter Notify template and generates the corresponding PDF forecast for each school. The email and PDF use the current calendar month; the PDF includes the full April-to-March forecast.

Run it from the repository root, passing the JSON file path as the task argument:

```sh
bundle exec rake "energy:send_gas_price_updates[path/to/pricing.json]"
```

The JSON must have a top-level `contacts` array. Each contact has a `Contact Email Address` and a `schools` array. Each school needs `School Name`, `School URN`, `School Postcode`, and a `meters` array containing between 1 and 9 meters. Each meter needs an `mprn`, `Non-COG Unit rate (p/kWh)`, `Daily Charge (£/day)`, and monthly COG and total unit-rate values for every month from April through March. The monthly value keys follow this pattern:

```text
"April Monthly COG (p/kWh)"
"April Total Unit Rate (p/kWh)"
```

For example, the file structure is:

```json
{
  "contacts": [
    {
      "Contact Email Address": "energy@example.org",
      "schools": [
        {
          "School Name": "Example School",
          "School URN": 100001,
          "School Postcode": "AA1 1AA",
          "meters": [
            {
              "mprn": "0000000001",
              "Non-COG Unit rate (p/kWh)": 0.1233,
              "Daily Charge (£/day)": 3.113,
              "April Monthly COG (p/kWh)": 2.8685,
              "April Total Unit Rate (p/kWh)": 2.9918
            }
          ]
        }
      ]
    }
  ]
}
```

This example shows the shape only: include both rate fields for all 12 forecast months on every meter before running the task. If a school has multiple meters, their COG value for the current month must be the same. The generated rate values are rounded to three decimal places in the email and PDF.

The task sends real emails as it processes the file and has no dry-run mode. Check the recipient addresses, school and meter data, `NOTIFY_API_KEY`, and the configured gas price Notify template IDs before running it. If processing fails, the task stops and raises the error; schools processed earlier in the file may already have received their emails.
