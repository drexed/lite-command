# frozen_string_literal: true

class AnonymousCommand < Lite::Command::Base

  def self.model_name
    ActiveModel::Name.new(self, nil, "anonymous_command")
  end

  def call
    # Do nothing
  end

end
