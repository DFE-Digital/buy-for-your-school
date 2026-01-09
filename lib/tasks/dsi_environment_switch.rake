# frozen_string_literal: true

namespace :dsi do
  desc "Update DSI UIDs when switching DSI environments (e.g., staging → test)"
  task :switch_environment, [:csv_path] => :environment do |_t, args|
    # Usage:
    #   rake dsi:switch_environment[path/to/uid_mappings.csv]
    #
    # CSV format (with header):
    #   email,pp_dsi_uid,test_dsi_uid
    #   user@example.com,old-uid,new-uid-from-dsi-test
    #
    # Or run interactively:
    #   rake dsi:switch_environment
    #
    # This will:
    #   1. Update users.dfe_sign_in_uid
    #   2. Update support_agents.dsi_uid
    #   3. Update support_evaluators.dsi_uid
    #   4. Update support_contract_recipients.dsi_uid

    mappings = if args[:csv_path]
      load_mappings_from_csv(args[:csv_path])
    else
      puts "No CSV provided. Enter mappings manually (empty email to finish):"
      collect_mappings_interactively
    end

    if mappings.empty?
      puts "No mappings provided. Exiting."
      exit
    end

    puts "\n=== DSI Environment Switch ==="
    puts "Processing #{mappings.size} mapping(s)...\n\n"

    ActiveRecord::Base.transaction do
      mappings.each do |email, new_uid|
        update_records_for_email(email, new_uid)
      end
    end

    puts "\n=== Complete ==="
  end

  desc "Preview what would be updated (dry run)"
  task :switch_environment_preview, [:csv_path] => :environment do |_t, args|
    mappings = if args[:csv_path]
      load_mappings_from_csv(args[:csv_path])
    else
      puts "No CSV provided. Enter mappings manually (empty email to finish):"
      collect_mappings_interactively
    end

    if mappings.empty?
      puts "No mappings provided. Exiting."
      exit
    end

    puts "\n=== DSI Environment Switch Preview (Dry Run) ==="
    puts "Would process #{mappings.size} mapping(s)...\n\n"

    mappings.each do |email, new_uid|
      preview_records_for_email(email, new_uid)
    end
  end

  def load_mappings_from_csv(path)
    require "csv"
    mappings = {}
    CSV.foreach(path, headers: true) do |row|
      email = row[0]
      new_uid = row[2] # test_dsi_uid is the 3rd column
      mappings[email.strip.downcase] = new_uid.strip if email.present? && new_uid.present?
    end
    mappings
  end

  def collect_mappings_interactively
    mappings = {}
    loop do
      print "Email: "
      email = $stdin.gets.chomp
      break if email.blank?

      print "New DSI UID: "
      new_uid = $stdin.gets.chomp
      next if new_uid.blank?

      mappings[email.downcase] = new_uid
    end
    mappings
  end

  def update_records_for_email(email, new_uid)
    puts "--- #{email} → #{new_uid} ---"

    # Update User
    user = User.find_by("lower(email) = ?", email.downcase)
    if user
      old_uid = user.dfe_sign_in_uid
      user.update!(dfe_sign_in_uid: new_uid)
      puts "  ✓ User: #{old_uid} → #{new_uid}"
    else
      puts "  - User: not found"
    end

    # Update Support::Agent
    agent = Support::Agent.find_by("lower(email) = ?", email.downcase)
    if agent
      old_uid = agent.dsi_uid
      agent.update!(dsi_uid: new_uid)
      puts "  ✓ Support::Agent: #{old_uid} → #{new_uid}"
    else
      puts "  - Support::Agent: not found"
    end

    # Update Support::Evaluator (may have multiple)
    evaluators = Support::Evaluator.where("lower(email) = ?", email.downcase)
    if evaluators.any?
      evaluators.update_all(dsi_uid: new_uid)
      puts "  ✓ Support::Evaluator: #{evaluators.count} record(s) updated"
    else
      puts "  - Support::Evaluator: not found"
    end

    # Update Support::ContractRecipient (may have multiple)
    recipients = Support::ContractRecipient.where("lower(email) = ?", email.downcase)
    if recipients.any?
      recipients.update_all(dsi_uid: new_uid)
      puts "  ✓ Support::ContractRecipient: #{recipients.count} record(s) updated"
    else
      puts "  - Support::ContractRecipient: not found"
    end

    puts ""
  end

  def preview_records_for_email(email, new_uid)
    puts "--- #{email} → #{new_uid} ---"

    user = User.find_by("lower(email) = ?", email.downcase)
    if user
      puts "  User: #{user.dfe_sign_in_uid} → #{new_uid}"
    else
      puts "  User: not found"
    end

    agent = Support::Agent.find_by("lower(email) = ?", email.downcase)
    if agent
      puts "  Support::Agent: #{agent.dsi_uid} → #{new_uid}"
    else
      puts "  Support::Agent: not found"
    end

    evaluators = Support::Evaluator.where("lower(email) = ?", email.downcase)
    puts "  Support::Evaluator: #{evaluators.count} record(s) would be updated"

    recipients = Support::ContractRecipient.where("lower(email) = ?", email.downcase)
    puts "  Support::ContractRecipient: #{recipients.count} record(s) would be updated"

    puts ""
  end
end

