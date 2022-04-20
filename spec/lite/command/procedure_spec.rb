# frozen_string_literal: true

require 'spec_helper'

class FooProcedureCommand < Lite::Command::Procedure

  def execute
    SecureRandom.hex(6)
  end

end

class ParComplexCommand < Lite::Command::Complex

  include Lite::Command::Extensions::Errors

  def execute
    SecureRandom.hex(6)
  end

end

class PazComplexCommand < Lite::Command::Complex

  include Lite::Command::Extensions::Errors

  def execute
    SecureRandom.hex('x123')
  rescue StandardError
    errors.add(:field, 'error message')
    nil
  end

end

RSpec.describe Lite::Command::Procedure do
  let(:steps) do
    [
      ParComplexCommand.new,
      ParComplexCommand.new,
      ParComplexCommand.new
    ]
  end
  let(:errored_step) do
    {
      index: 1,
      step: 2,
      name: 'PazComplexCommand',
      args: [],
      errors: ['field error message']
    }
  end

  describe '.call' do
    it 'to be true when returns without error' do
      procedure = described_class.call(steps)

      expect(procedure.success?).to be(true)
    end

    it 'to be all correct result class name without errors' do
      procedure = described_class.call(steps)

      expect(procedure.result.map { |s| s.class.name }).to eq(%w[String String String])
    end

    it 'to be false when returns with error' do
      steps.first.errors.add(:field, 'error message')
      procedure = described_class.call(steps)

      expect(procedure.success?).to be(false)
    end

    it 'to be all correct result class name with errors' do
      steps[1] = PazComplexCommand.new
      procedure = described_class.call(steps)

      expect(procedure.errors.key?(:field)).to be(true)
      expect(procedure.result.map { |s| s.class.name }).to eq(%w[String String])
      expect(procedure.failed_steps).to include(errored_step)
    end

    it 'to be all correct result class name with errors and exit on failure' do
      steps[1] = PazComplexCommand.new
      procedure = described_class.new(steps)
      procedure.exit_on_failure = true
      procedure.call

      expect(procedure.errors.key?(:field)).to be(true)
      expect(procedure.result.map { |s| s.class.name }).to eq(%w[String])
      expect(procedure.failed_steps).to include(errored_step)
    end
  end

end
