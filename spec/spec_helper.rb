# frozen_string_literal: true

require "bundler/setup"
require "securerandom"
require "rails/generators"
require "active_support"
require "generator_spec"

require "lite/command"

spec_path = Pathname.new(File.expand_path("../spec", File.dirname(__FILE__)))

Dir.glob(spec_path.join("support/**/*.rb"))
   .sort_by { |f| [f.split("/").size, f] }
   .each { |f| load(f) }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after(:all) do
    temp_path = spec_path.join("generators/tmp")
    FileUtils.remove_dir(temp_path) if File.directory?(temp_path)

    temp_path = spec_path.join("generators/lite/tmp")
    FileUtils.remove_dir(temp_path) if File.directory?(temp_path)
  end

  config.before do
    [
      Sequences::FailureSequence,
      Sequences::SuccessSequence,
      Child::NoopCommand,
      Child::SuccessCommand,
      ErrorCommand,
      ExceptionCommand,
      FailureCommand,
      InvalidCommand,
      NoopCommand,
      SuccessCommand,
      ThrownCommand
    ].each do |klass|
      allow_any_instance_of(klass).to receive(:freeze_execution_objects).and_return(true)
    end
  end
end
