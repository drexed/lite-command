# frozen_string_literal: true

require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before { DatabaseCleaner.start }
  config.after { DatabaseCleaner.clean }
end
