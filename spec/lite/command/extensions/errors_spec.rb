# frozen_string_literal: true

require 'spec_helper'

class BarErrorsService < Lite::Command::Complex

  include Lite::Command::Extensions::Errors

  def initialize; end

  def command
    SecureRandom.hex(6)
  end

end

RSpec.describe Lite::Command::Extensions::Errors do
  let(:bar) { BarErrorsService.new }

  describe '.perform' do
    it 'to be success yield results' do
      s1 = 'success'
      s2 = 'failure'

      BarErrorsService.perform do |result, success, failure|
        expect(result.size).to eq(12)
        expect(success.call { s1 }).to eq(s1)
        expect(failure.call { s2 }).to eq(nil)
      end
    end
  end

  describe '.errors' do
    it 'to be an Lite::Errors::Messages object' do
      expect(bar.errors).to be_a(Lite::Errors::Messages)
    end
  end

  describe '.fail!' do
    it 'to be an Lite::Command::ValidationError error' do
      expect { bar.fail! }.to raise_error(Lite::Command::ValidationError)
    end
  end

  describe '.failure?' do
    it 'to be false' do
      bar.call

      expect(bar.failure?).to eq(false)
    end

    it 'to be true' do
      bar.call
      bar.errors.add(:field, 'error message')

      expect(bar.failure?).to eq(true)
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

  describe '.result!' do
    it 'to be true' do
      bar.call

      expect(bar.result!).to be_a(String)
    end

    it 'to be an Lite::Command::ValidationError error' do
      bar.call
      bar.errors.add(:field, 'error message')

      expect { bar.result! }.to raise_error(Lite::Command::ValidationError)
    end
  end

  describe '.status' do
    it 'to be :pending' do
      expect(bar.status).to eq(:pending)
    end

    it 'to be :success' do
      bar.call

      expect(bar.status).to eq(:success)
    end

    it 'to be :failure' do
      bar.call
      bar.errors.add(:field, 'error message')

      expect(bar.status).to eq(:failure)
    end
  end

  describe '.success?' do
    it 'to be true' do
      bar.call

      expect(bar.success?).to eq(true)
    end

    it 'to be false' do
      bar.call
      bar.errors.add(:field, 'error message')

      expect(bar.success?).to eq(false)
    end
  end

  describe '.validate!' do
    it 'to be true' do
      bar.call

      expect(bar.validate!).to eq(true)
    end

    it 'to be an Lite::Command::ValidationError error' do
      bar.call
      bar.errors.add(:field, 'error message')

      expect { bar.validate! }.to raise_error(Lite::Command::ValidationError)
    end
  end

end
