# frozen_string_literal: true

module CommandHelpers

  class PassStep < Lite::Command::Base

    def call
      # Do nothing, success
    end

    private

    def trace_key
      :pass
    end

  end

  class NoopStep < Lite::Command::Base

    def call
      noop!("Nooped step")
    end

    private

    def trace_key
      :pass
    end

  end

  class InvalidStep < Lite::Command::Base

    def call
      invalid!("Invalid step")
    end

  end

  class FailStep < Lite::Command::Base

    def call
      fail!("Failed step")
    end

  end

  class ErrorStep < Lite::Command::Base

    def call
      error!("Errored step")
    end

  end

  class ExceptionStep < Lite::Command::Base

    def call
      raise "Exception step"
    end

  end

  class ThrownStep < Lite::Command::Base

    def call
      step = PassStep.call(context)
      throw!(step)

      step = NoopStep.call(context)
      throw!(step)
    end

    private

    def trace_key
      :thrown
    end

  end

end
