# frozen_string_literal: true

require "notify/email"

module Energy
  class Emails::GasPriceUpdate
    SENDER_NAME = "DfE Energy for Schools Team"
    MONTHS = %w[January February March April May June July August September October November December].freeze
    RECIPIENT = Struct.new(:email, :first_name, :last_name)

    def initialize(contact:, school:, month: Date.current.strftime("%B"), sender_name: SENDER_NAME, client: nil)
      @contact = contact
      @school = school
      @month = month.to_s.capitalize
      @sender_name = sender_name
      @client = client

      validate_input!
    end

    delegate :call, to: :notify_email

    def template_id
      if meters.one?
        Support::EmailTemplates::IDS[:energy_gas_price_update_single_meter]
      else
        Support::EmailTemplates::IDS[:energy_gas_price_update_multi_meter]
      end
    end

    def personalisation
      substitutions = {
        month: @month,
        price_per_kwh: GasPriceFormatting.format(monthly_cog),
        sender_name: @sender_name,
      }

      if meters.one?
        meter = meters.first
        substitutions.merge!(
          meter_number: meter.fetch("mprn"),
          monthly_total_amount: "#{GasPriceFormatting.format(meter.fetch("#{@month} Total Unit Rate (p/kWh)"))} p/kWh",
          fixed_unit_rate: "#{GasPriceFormatting.format(meter.fetch('Non-COG Unit rate (p/kWh)'))} p/kWh",
          "£/day": "£#{GasPriceFormatting.format(meter.fetch('Daily Charge (£/day)'))}/day",
        )
      end

      substitutions
    end

  private

    def notify_email
      @notify_email ||= Notify::Email.new(
        recipient: RECIPIENT.new(@contact.fetch("Contact Email Address"), nil, nil),
        template: template_id,
        variables: personalisation,
        client: @client || Notifications::Client.new(ENV["NOTIFY_API_KEY"]),
      )
    end

    def meters
      @meters ||= @school.fetch("meters")
    end

    def monthly_cog
      meters.first.fetch("#{@month} Monthly COG (p/kWh)")
    end

    def validate_input!
      raise ArgumentError, "Unknown gas price update month: #{@month}" unless MONTHS.include?(@month)
      raise ArgumentError, "A school must have at least one gas meter" if meters.empty?

      if meters.map { |meter| meter.fetch("#{@month} Monthly COG (p/kWh)") }.uniq.many?
        raise ArgumentError, "Gas meters for a school must have the same monthly COG rate"
      end
    end
  end
end
