# frozen_string_literal: true

class ApplicationCommand < Lite::Command::Base

  # Add inheritable logic here...

  private

  def trace_hook(method)
    ctx.hooks ||= []
    ctx.hooks << "#{self.class.name}.#{method}"
  end

  def on_before_validation
    trace_hook(__method__)
  end

  def on_before_execution
    trace_hook(__method__)
  end

  def on_after_execution
    trace_hook(__method__)
  end

  def on_success
    trace_hook(__method__)
  end

  Lite::Command::FAULTS.each do |f|
    define_method(:"on_#{f}") { |_fault| trace_hook(__method__) }
  end

  Lite::Command::STATES.each do |s|
    define_method(:"on_#{s}") { trace_hook(__method__) }
  end

end
