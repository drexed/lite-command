# frozen_string_literal: true

require 'lite/memoize' unless defined?(Lite::Memoize)

module Lite
  module Command
    module Extensions
      module Memoize

        def cache
          @cache ||= Lite::Memoize::Instance.new
        end

      end
    end
  end
end
