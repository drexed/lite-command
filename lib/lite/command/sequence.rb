# frozen_string_literal: true

module Lite
  module Command
    class Sequence < Base

      def self.step(*commands, **options)
        steps << {
          commands: commands.flatten,
          options:
        }
      end

      def self.steps
        @steps ||= []
      end

      def call
        self.class.steps.each do |steps|
          step!(steps[:commands], steps[:options])
        end
      end

      private

      def step!(commands, _options = {})
        # run = if options[:if]
        #         options[:if].is_a?(Symbol) ? send(options[:if]) : instance_eval(&options[:if])
        #       else
        #         true
        #       end
        # return unless run

        commands.each do |command|
          cmd = command.call(context)
          throw!(cmd) unless cmd.ok?
        end
      end

    end
  end
end
