module SpecScreenshotHelper
  # rubocop:disable Lint/Debugger
  # rubocop:disable Lint/SuppressedException

  def save_timestamped_screenshot
    file = Time.zone.now.utc.strftime("screenshot-%Y-%m-%d-%H-%M-%S.%3N.png")
    page.save_screenshot Rails.root.join("tmp", "screenshots", file)
  rescue Capybara::NotSupportedByDriverError
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
end

RSpec.configure do |config|
  config.include SpecScreenshotHelper if ENV.key?("SCREENSHOT")
end
