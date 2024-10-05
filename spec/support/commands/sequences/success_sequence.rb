# frozen_string_literal: true

module Sequences
  class SuccessSequence < BaseSequence

    step SuccessCommand
    step NoopCommand
    step [SuccessCommand, Child::SuccessCommand]

  end
end
