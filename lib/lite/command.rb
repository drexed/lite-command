# frozen_string_literal: true

require "forwardable" unless defined?(Forwardable)
require "generators/rails/command_generator" if defined?(Rails::Generators)

require "lite/command/version"
require "lite/command/internals/runnable"
require "lite/command/internals/callable"
require "lite/command/internals/executable"
require "lite/command/internals/resultable"
require "lite/command/metadata/tracing"
require "lite/command/fault"
require "lite/command/construct"
require "lite/command/trace"
require "lite/command/results"
require "lite/command/base"
