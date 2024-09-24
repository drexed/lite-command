# frozen_string_literal: true

require "generators/rails/command_generator" if defined?(Rails::Generators)

require "lite/command/version"
require "lite/command/fault"

require "lite/command/step/callable"
require "lite/command/step/executable"
require "lite/command/step/resultable"
require "lite/command/step/traceable"

require "lite/command/construct"
require "lite/command/results"
require "lite/command/base"
require "lite/command/trace"
