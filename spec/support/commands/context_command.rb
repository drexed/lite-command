# frozen_string_literal: true

class ContextCommand < BaseCommand

  attribute :a, required: true, type: Integer
  attribute :storage, required: true
  attribute :b, :c, required: true, from: :storage
  attribute :d, :e
  attribute :f, from: :storage

  def call
    ctx.result = [
      a, b, c, d, e, f
    ].sum(&:to_i)
  end

end
