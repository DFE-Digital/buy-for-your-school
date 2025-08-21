RSpec.configure do |config|
  config.after(:each, type: :system) do |example|
    if example.exception
      if page.driver.browser.respond_to?(:logs)
        warn page.driver.browser.logs.get(:browser)
      end

      save_timestamped_screenshot(page, example.description)
    end
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
