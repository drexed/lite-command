# frozen_string_literal: true

require 'generators/rails/command_generator' if defined?(Rails::Generators)

require 'lite/command/version'

require 'lite/command/extensions/errors'
require 'lite/command/extensions/memoize'
require 'lite/command/extensions/propagation'

require 'lite/command/exceptions'
require 'lite/command/states'
require 'lite/command/simple'
require 'lite/command/complex'
require 'lite/command/procedure'
