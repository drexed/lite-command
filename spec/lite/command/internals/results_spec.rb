# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lite::Command::Internals::Results do
  # config.before do
  #   [
  #     ValidationTokenCommand
  #   ].each do |klass|
  #     allow_any_instance_of(klass).to receive(:freeze_execution_objects).and_return(true)
  #   end
  # end

  # context "when noop" do
  #   let(:command_class) { NoopCommand }

  #   it "returns a noop status" do
  #     expect(command.results).not_to be_empty
  #     expect(command.to_hash).to eq(
  #       index: 1,
  #       cmd_id: "018c2b95-b764-7615-a924-cc5b910ed1e5",
  #       command: "NoopCommand",
  #       outcome: "noop",
  #       state: "interrupted",
  #       status: "noop",
  #       reason: "[!] command stopped due to noop",
  #       caused_by: 1,
  #       thrown_by: 1,
  #       runtime: 0.0123
  #     )
  #   end
  # end
end
