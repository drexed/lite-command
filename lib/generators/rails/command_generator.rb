# frozen_string_literal: true

require 'rails/generators'

module Rails
  class CommandGenerator < Rails::Generators::NamedBase

    source_root File.expand_path('../templates', __FILE__)
    check_class_collision suffix: 'Command'

    def copy_files
      path = File.join('app', 'commands', class_path, "#{file_name}_command.rb")
      empty_directory('app/commands')
      template('command.rb.tt', path)
    end

    private

    def file_name
      @_file_name ||= remove_possible_suffix(super)
    end

    def remove_possible_suffix(name)
      name.sub(/_?command$/i, '')
    end

  end
end
