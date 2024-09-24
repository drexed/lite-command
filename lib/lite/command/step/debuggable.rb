# frozen_string_literal: true

module Lite
  module Command
    module Step
      module Debuggable

        extend ActiveSupport::Concern

        included { attr_reader :print_format }

        def state_color
          case state
          when PENDING then :gray
          when DNF then :blue
          else :default
          end
        end

        def colored_state
          state.colorize(state_color)
        end

        def status_color
          case status
          when SUCCESS then :green
          when NOOP then :yellow
          when FAILURE then :red
          else :default
          end
        end

        def colored_status
          status.colorize(status_color)
        end

        def colored_result
          if pending? || thrown_fault?
            colored_state
          else
            colored_status
          end
        end

        def to_table
          Terminal::Table.new do |t|
            t.style = { width: 135 }
            t.title = print_title.colorize(color: results.first.status_color, mode: :bold) if print_title.present?
            t.headings = ["#", "Step", "Result", "Reason", "Trace", "Runtime"]
            t.rows = results.map do |step|
              [
                step.trace.index,
                step.class.name,
                *if step.success?
                   [step.colored_status, "--"]
                 elsif step.faulter?
                   [step.colored_status, step.reason]
                 else
                   [step.colored_result, "#{step.status} thrown from step #{step.thrower.trace.index}"]
                 end,
                step.trace.to_position_fs,
                step.metadata.runtime
              ]
            end
          end
        rescue StandardError => e
          "[!] Failed to generate table due to: #{e.class} #{e.message}".colorize(:red)
        end
        alias to_t to_table

        def print(format)
          case format
          when :hash then puts; pp to_hash; puts
          when :table then puts; puts to_table; puts
          end
        end

        private

        def print_execution_results
          print(print_format)
        end

      end
    end
  end
end
