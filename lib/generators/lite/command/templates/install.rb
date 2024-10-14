# frozen_string_literal: true

Lite::Command.configure do |config|
  config.max_call_depth = Float::INFINITY
  config.raise_dynamic_errors = false
end
