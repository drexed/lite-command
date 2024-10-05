# frozen_string_literal: true

module Sequences
  class FailureSequence < BaseSequence

    step SuccessCommand
    step FailureCommand
    step [SuccessCommand, Child::SuccessCommand]

  end
end
