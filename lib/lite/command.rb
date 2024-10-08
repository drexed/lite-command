# frozen_string_literal: true

require "generators/rails/command_generator" if defined?(Rails::Generators)

require "lite/command/version"
require "lite/command/utils"
require "lite/command/context"
require "lite/command/attribute"
require "lite/command/attribute_validator"
require "lite/command/fault"
require "lite/command/fault_streamer"
require "lite/command/internals/context"
require "lite/command/internals/call"
require "lite/command/internals/execute"
require "lite/command/internals/fault"
require "lite/command/internals/result"
require "lite/command/base"
require "lite/command/step"
require "lite/command/sequence"
