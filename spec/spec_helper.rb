# frozen_string_literal: true

require 'bundler/setup'
require 'securerandom'
require 'rails/generators'
require 'active_record'
require 'lite/command'
require 'generator_spec'

spec_path = Pathname.new(File.expand_path('../spec', File.dirname(__FILE__)))

%w[config models].each do |dir|
  Dir.each_child(spec_path.join("support/#{dir}")) do |f|
    load(spec_path.join("support/#{dir}/#{f}"))
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after(:all) do
    temp_path = spec_path.join('generators/tmp')
    FileUtils.remove_dir(temp_path) if File.directory?(temp_path)

    temp_path = spec_path.join('generators/lite/tmp')
    FileUtils.remove_dir(temp_path) if File.directory?(temp_path)
  end
end
