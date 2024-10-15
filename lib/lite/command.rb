# frozen_string_literal: true

if defined?(Rails::Generators)
  require "generators/lite/command/install_generator"
  require "generators/rails/command_generator"
end

require "lite/command/version"
require "lite/command/configuration"
require "lite/command/utils"
require "lite/command/context"
require "lite/command/fault"
require "lite/command/fault_streamer"
require "lite/command/internals/attributes"
require "lite/command/internals/calls"
require "lite/command/internals/executions"
require "lite/command/internals/faults"
require "lite/command/internals/results"
require "lite/command/base"
require "lite/command/step"
require "lite/command/sequence"
