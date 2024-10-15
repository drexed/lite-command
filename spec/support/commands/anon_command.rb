# frozen_string_literal: true

class AnonCommand < Lite::Command::Base

  def self.model_name
    ActiveModel::Name.new(self, nil, "anon_command")
  end

  def call
    # Do nothing
  end

end
