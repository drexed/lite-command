# frozen_string_literal: true

module CommandHelpers

  class PassStep

    include Lite::Command::Step

    def call
      # Do nothing, success
    end

    private

    def trace_key
      :pass
    end

  end

  class NoopStep

    include Lite::Command::Step

    def call
      noop!("Nooped step")
    end

    private

    def trace_key
      :pass
    end

  end

  class FailStep

    include Lite::Command::Step

    def call
      fail!("Failed step")
    end

  end

  class ErrorStep

    include Lite::Command::Step

    def call
      raise "Errored step"
    end

  end

  class ThrownStep

    include Lite::Command::Step

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
