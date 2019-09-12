# frozen_string_literal: true

require 'spec_helper'

class BarMemoizeCommand < Lite::Command::Complex

  include Lite::Command::Extensions::Memoize

  def initialize; end

  def execute
    memoized
  end

  def memoized
    cache.memoize { SecureRandom.hex(6) }
  end

end

RSpec.describe Lite::Command::Extensions::Memoize do
  let(:bar) { BarMemoizeCommand.new }

  describe '.cache' do
    it 'to be an Lite::Memoize::Instance object' do
      expect(bar.cache).to be_a(Lite::Memoize::Instance)
    end
  end

  describe '.recall!' do
    it 'to be different random strings' do
      bar.call
      first_result = bar.result

      bar.recall!
      second_result = bar.result

      expect(second_result).not_to eq(first_result)
    end
  end

end
