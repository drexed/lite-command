# frozen_string_literal: true

module AaaHelpers

  # Callback hook helpers

  private

  def store_callback_executor(method)
    ctx.callbacks ||= []
    ctx.callbacks << "#{self.class.name}.#{method}"
  end

  def on_before_execution
    store_callback_executor(__method__)
  end

  def on_after_execution
    store_callback_executor(__method__)
  end

  def on_success
    store_callback_executor(__method__)
  end

  Lite::Command::FAULTS.each do |f|
    define_method(:"on_#{f}") do |_fault|
      store_callback_executor(__method__)
    end
  end

  Lite::Command::STATES.each do |s|
    define_method(:"on_#{s}") do
      store_callback_executor(__method__)
    end
  end

end
