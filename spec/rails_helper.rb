require 'simplecov'
require 'webdrivers'

SimpleCov.start 'rails' do
  if ENV['CI']
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end

  add_filter %w[version.rb initializer.rb]
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'capybara-screenshot/rspec'
# Add additional requires below this line. Rails is not loaded until this point!
require 'active_fedora/cleaner'

Capybara.server = :webrick
Capybara::Screenshot.autosave_on_failure = false

if ENV['IN_DOCKER'].present? || ENV['HUB_URL'].present?
  args = %w[disable-gpu no-sandbox whitelisted-ips window-size=1400,1400]
  args.push('headless') if ActiveModel::Type::Boolean.new.cast(ENV['CHROME_HEADLESS_MODE'])

  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome("goog:chromeOptions" => { args: args })

  Capybara.register_driver :selenium_chrome_headless_sandboxless do |app|
    driver = Capybara::Selenium::Driver.new(app,
                                       browser: :remote,
                                       desired_capabilities: capabilities,
                                       url: ENV['HUB_URL'])

    # Fix for capybara vs remote files. Selenium handles this for us
    driver.browser.file_detector = lambda do |argss|
      str = argss.first.to_s
      str if File.exist?(str)
    end

    driver
  end

  Capybara.server_host = '0.0.0.0'
  Capybara.server_port = 3010
  Capybara.javascript_driver = :selenium_chrome_headless_sandboxless
  ip = IPSocket.getaddress(Socket.gethostname)
  Capybara.app_host = "http://#{ip}:#{Capybara.server_port}"
  Capybara.default_driver = :selenium_chrome_headless_sandboxless
else
  # this is for github actions only

  Webdrivers::Chromedriver.required_version = '106.0.5249.21'
  custom_chrome_path = '/opt/hostedtoolcache/chromium/1036826/x64/chrome'

  # Adding chromedriver for js testing.
Capybara.register_driver :headless_chrome do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.headless!
  browser_options.args << '--window-size=1920,1080'
  browser_options.args << '--no-sandbox'
  browser_options.args << '--disable-dev-shm-usage'
  browser_options.args << '--disable-gpu'
  browser_options.binary = custom_chrome_path
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

# For debugging JS tests - some tests involving mouse movements require headless mode.
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

# Change to :chrome for js test debugging
Capybara.javascript_driver = :headless_chrome


end

# Change to :chrome for js test debugging


# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  include LdapManager

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.

  # Documentation claims this defaults to 'true', but I had to set it to get it to work.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  #
  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers, type: :system

  #Trove is based off these collection types existing, so might as well create them once, here.
  config.before(:suite) do
    FactoryBot.create(:personal_collection_type)
    FactoryBot.create(:course_collection_type)
  end
  config.after(:suite) do
    Hyrax::CollectionType.destroy_all
  end

  config.after(:each) do
    ActiveFedora::Cleaner.clean!
  end
end
