# frozen_string_literal: true

require "generators/rails/command_generator" if defined?(Rails::Generators)

require "lite/command/version"
require "lite/command/internals/callable"
require "lite/command/internals/executable"
require "lite/command/internals/resultable"
require "lite/command/fault"
require "lite/command/context"
require "lite/command/base"
