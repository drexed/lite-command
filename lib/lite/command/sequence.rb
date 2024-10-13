# frozen_string_literal: true

module Lite
  module Command
    class Sequence < Base

      def self.step(*commands, **options)
        commands.flatten.each do |command|
          steps << Step.new(command, options)
        end
      end

      def self.steps
        @steps ||= []
      end

      def call
        self.class.steps.each do |step|
          next unless step.run?(self)

          cmd = step.command.call(context)
          throw!(cmd) if cmd.bad?
        end
      end

    end
  end
end
