module SpecScreenshotHelper
  # rubocop:disable Lint/Debugger
  # rubocop:disable Lint/SuppressedException

  def save_timestamped_screenshot(page, name)
    timestamp = Time.zone.now.strftime("%Y-%m-%d-%H-%M-%S.%3N")
    screenshot = sprintf("screenshot-%s-%s.png", timestamp, name.gsub(/\W+/, "_"))

    path = if ENV.key?("SCREENSHOT_PATH")
              File.join(ENV.fetch("SCREENSHOT_PATH"), screenshot)
           else
              Rails.root.join("tmp", "capybara", screenshot)
           end

    page.save_screenshot(path)

    puts "Screenshot saved to: #{path}"
  rescue Capybara::NotSupportedByDriverError
    warn "Screenshot not supported by current Capybara driver."
  end

  # rubocop:enable Lint/SuppressedException
  # rubocop:enable Lint/Debugger

  def click_link(*, **, &)
    save_timestamped_screenshot
    super
  end

  def click_button(*, **, &)
    save_timestamped_screenshot
    super
  end

  def visit(*, **, &)
    super
    save_timestamped_screenshot
  end
end

RSpec.configure do |config|
  config.include SpecScreenshotHelper if ENV.key?("SCREENSHOT")
end
