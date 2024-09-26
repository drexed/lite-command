# frozen_string_literal: true

module Lite
  module Command
    class Base
      extend Forwardable

      include Lite::Command::Internals::Traceable
      include Lite::Command::Internals::Callable
      include Lite::Command::Internals::Executable
      include Lite::Command::Internals::Resultable

      attr_reader :context, :metadata

      def initialize(context = {})
        @context = Lite::Command::Construct.build(context)
        @metadata = Lite::Command::Construct.init
      end

    end
  end
end
