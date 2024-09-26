# frozen_string_literal: true

module CommandHelpers

  class PassCommand < Lite::Command::Base

    def call
      # Do nothing, success
    end

    private

    def trace_key
      :pass
    end

  end

  class NoopCommand < Lite::Command::Base

    def call
      noop!("Nooped command")
    end

    private

    def trace_key
      :pass
    end

  end

  class InvalidCommand < Lite::Command::Base

    def call
      invalid!("Invalid command")
    end

  end

  class FailCommand < Lite::Command::Base

    def call
      fail!("Failed command")
    end

  end

  class ErrorCommand < Lite::Command::Base

    def call
      error!("Errored command")
    end

  end

  class ExceptionCommand < Lite::Command::Base

    def call
      raise "Exception command"
    end

  end

  class ThrownCommand < Lite::Command::Base

    def call
      command = PassCommand.call(context)
      throw!(command)

      command = NoopCommand.call(context)
      throw!(command)
    end

    private

    def trace_key
      :thrown
    end

  end

end
