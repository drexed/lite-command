# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rails::CommandGenerator, type: :generator do
  destination(File.expand_path('../../tmp', __FILE__))

  before do
    prepare_destination
    run_generator(%w[v1/users/age])
  end

  let(:command_path) { 'spec/generators/tmp/app/commands/v1/users/age_command.rb' }

  describe '#generator' do
    context 'when generating app files' do
      it 'to be true when command file exists' do
        expect(File.exist?(command_path)).to eq(true)
      end

      it 'to include the proper markup' do
        command_file = File.read(command_path)
        text_snippet = 'class V1::Users::AgeCommand < ApplicationCommand'

        expect(command_file.include?(text_snippet)).to eq(true)
      end
    end
  end

end
