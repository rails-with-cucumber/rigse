
# This section is based on the file generated by running:
#   rails generate rspec:install
require File.expand_path("../../config/environment", __FILE__)

Rails.env = ENV['RAILS_ENV']

require 'factory_girl'

# Mute FactoryGirl deprecation warnings...
ActiveSupport::Deprecation.behavior = lambda do |msg, stack|
  unless /FactoryGirl|after_create/ =~ msg
    ActiveSupport::Deprecation::DEFAULT_BEHAVIORS[:stderr].call(msg,stack) # whichever handlers you want - this is the default
  end
end

require 'rspec/rails'
require 'rspec/mocks'

# *** customizations ***

# Add this to load Capybara integration:
# The Capybara DSL is automatically mixed in to specs running in
# spec/requests, spec/integration or spec/acceptance.
#
# You can use the Capybara DSL in any rspec test if you add:
#  ',:type => :request'  to the describe invocation ...
#
require 'capybara/rspec'
require 'capybara/rails'
require 'webmock/rspec'

require 'capybara-screenshot/rspec'

Capybara::Screenshot.prune_strategy = :keep_last_run

Dir.mkdir "tmp/capybara" rescue nil
Capybara.save_and_open_page_path = "tmp/capybara"

require 'remarkable_activerecord'
# we have to include our extensions in the rspec configuration block
require File.expand_path("../support/rspec_extensions", __FILE__)
require File.expand_path("../support/authenticated_test_helper", __FILE__)
include AuthenticatedTestHelper
include AuthenticatedSystem

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = Rails.env == 'test'

  config.include FailsInThemes
  config.include Sprockets::Helpers::RailsHelper
  config.include Devise::TestHelpers, :type => :controller

end
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

if ActiveRecord::Migrator.new(:up, ::Rails.root.to_s + "/db/migrate").pending_migrations.empty?
  if Probe::ProbeType.count == 0
    puts
    puts "*** Probe configuration models need to be loaded into the test database to run the tests"
    puts "*** run: rake db:test:prepare"
    puts "RAILS_ENV: #{ENV['RAILS_ENV']}"
    puts "Rails.env: #{Rails.env}"
    puts "Database: #{ActiveRecord::Base.connection.current_database}"
    puts
    exit 1
  end
else
  puts
  puts "*** pending migrations need to be applied to run the tests"
  puts "*** run: rake db:test:prepare"
  puts "RAILS_ENV: #{ENV['RAILS_ENV']}"
  puts "Rails.env: #{Rails.env}"
  puts "Database: #{ActiveRecord::Base.connection.current_database}"
  puts
  exit 1
end

# I don't think this is necessary anymore with the latest factory_girl
@factories = Dir.glob(File.join(File.dirname(__FILE__), '../factories/*.rb')).each { |f| require(f) }
