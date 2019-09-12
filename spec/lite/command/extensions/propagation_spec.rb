# frozen_string_literal: true

require 'spec_helper'

class FooPropagationCommand < Lite::Command::Complex

  include Lite::Command::Extensions::Errors
  include Lite::Command::Extensions::Propagation

  def initialize(action)
    @action = action
  end

  def execute
    case @action
    when :fail then create_and_return!(User, name: nil)
    when :pass then create_and_return!(User, name: 'Doe')
    end
  end

end

RSpec.describe Lite::Command::Extensions::Propagation do

  describe '#propagation' do
    it 'to be false when the object fails' do
      foo = FooPropagationCommand.new(:fail)
      foo.call

      expect(foo.errors.empty?).to eq(false)
    end

    it 'to be true when the object passes' do
      foo = FooPropagationCommand.new(:pass)
      foo.call

      expect(foo.errors.empty?).to eq(true)
    end
  end

end
