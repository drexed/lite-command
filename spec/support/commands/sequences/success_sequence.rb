# frozen_string_literal: true

module Sequences
  class SuccessSequence < BaseSequence

    step SuccessCommand
    step NoopCommand
    step SuccessCommand, unless: proc { (1 + 1) == 2 }
    step FailureCommand, if: :bork?
    step [SuccessCommand, Child::SuccessCommand]

    private

    def bork?
      false
    end

  end
end
