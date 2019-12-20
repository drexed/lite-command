# frozen_string_literal: true

require 'lite/command/version'

%w[errors memoize propagation].each do |name|
  require "lite/command/extensions/#{name}"
end

%w[exceptions states complex simple].each do |name|
  require "lite/command/#{name}"
end

require 'generators/rails/command_generator'
