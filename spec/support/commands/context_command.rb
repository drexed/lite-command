# frozen_string_literal: true

class ContextCommand < BaseCommand

  required :a
  required :storage
  required :b, :c, from: :storage
  optional :d, :e
  optional :f, from: :storage

  def call
    ctx.result = [
      a, b, c, d, e, f
    ].map(&:to_i).sum
  end

end
