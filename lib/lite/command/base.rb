# frozen_string_literal: true

module Lite
  module Command
    class Base

      include Lite::Command::Step::Traceable
      include Lite::Command::Step::Callable
      include Lite::Command::Step::Executable
      include Lite::Command::Step::Resultable

      attr_reader :context, :metadata

      def initialize(context = {})
        @context  = Lite::Command::Construct.build(context)
        @metadata = Lite::Command::Construct.init
      end

    end
  end
end
