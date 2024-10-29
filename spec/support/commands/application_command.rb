# frozen_string_literal: true

class ApplicationCommand < Lite::Command::Base

  # Lifecycle hooks
  after_initialize  :after_initialize_hook
  before_validation :before_validation_hook
  after_validation  :after_validation_hook
  before_execution  :before_execution_hook
  after_execution   :after_execution_hook

  # Status hooks
  on_success :on_success_hook
  on_noop    :on_noop_hook
  on_invalid :on_invalid_hook
  on_failure :on_failure_hook
  on_error   :on_error_hook

  # State hooks
  on_pending     :on_pending_hook
  on_executing   :on_executing_hook
  on_complete    :on_complete_hook
  on_interrupted :on_interrupted_hook

  private

  def trace_hook(method)
    ctx.hooks ||= []
    ctx.hooks << "#{self.class.name}.#{method}"
  end

  Lite::Command::HOOKS.each do |h|
    define_method(:"#{h}_hook") { trace_hook(__method__) }
  end

end
