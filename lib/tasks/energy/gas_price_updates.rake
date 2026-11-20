# frozen_string_literal: true

namespace :energy do
  desc "Send monthly gas price update emails for each school in a pricing JSON file"
  task :send_gas_price_updates, [:input_file] => :environment do |_task, args|
    input_file = args[:input_file]
    raise ArgumentError, "Provide a pricing JSON file: rake energy:send_gas_price_updates[path/to/file.json]" if input_file.blank?

    pricing_data = JSON.parse(File.read(input_file))
    schools_count = 0
    puts "Starting gas price update emails from #{input_file}"

    pricing_data.fetch("contacts").each do |contact|
      contact.fetch("schools").each do |school|
        result = Energy::Emails::GasPriceUpdate.new(contact:, school:).call
        raise "Notify failed: #{result}" if result.is_a?(String)

        schools_count += 1
        puts "Sent gas price update for #{school.fetch('School Name')}"
      end
    end

    puts "Sent #{schools_count} gas price update emails"
  end
end
