# frozen_string_literal: true

RSpec.describe Lite::Command do

  it 'to be a version number' do
    expect(Lite::Command::VERSION).not_to be_nil
  end

end
