# frozen_string_literal: true

require 'lite/memoize'

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
