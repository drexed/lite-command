# Lite::Command

[![Gem Version](https://badge.fury.io/rb/lite-command.svg)](http://badge.fury.io/rb/lite-command)
[![Build Status](https://travis-ci.org/drexed/lite-command.svg?branch=master)](https://travis-ci.org/drexed/lite-command)

Lite::Command provides an API for building simple and complex command based service objects.
It provides mixins for handling errors and memoization to improve your object workflow productivity.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lite-command'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lite-command

## Table of Contents

* [Setup](#setup)
* [Simple](#simple)
* [Complex](#complex)
* [Extensions](#extensions)

## Setup

`rails g command NAME` will generate the following file:

```erb
app/commands/[NAME]_command.rb
```

If a `ApplicationCommand` file in the `app/commands` directory is available, the
generator will create file that inherit from `ApplicationCommand` if not it will
fallback to `Lite::Command::Complex`.

## Simple

Simple commands build quick class based calls but cannot be extended.
This is more of a traditional command service call as it only exposes a `call` method.

```ruby
class SearchMovies < Lite::Command::Simple

  # NOTE: This class method is required
  def self.execute(*args)
    { generate_fingerprint => movies_by_name }
  end

end
```

**Caller**

```ruby
SearchMovies.call('Toy Story')
```

## Complex

Complex commands can be used in instance and class based calls and
extended with access to errors and memoization.

You will then need to fill this class with the required `execute` method as shown below:

```ruby
class SearchMovies < Lite::Command::Complex

  def initialize(name)
    @name = name
  end

  # NOTE: This instance method is required
  def execute
    { generate_fingerprint => movies_by_name }
  end

  private

  def movies_by_name
    HTTP.get("http://movies.com?title=#{title}")
  end

  def generate_fingerprint
    Digest::MD5.hexdigest(movies_by_name)
  end

end
```

**Caller**

```ruby
command = SearchMovies.new('Toy Story')
command.called? #=> false
command.call    #=> { 'fingerprint_1' => [ 'Toy Story 1', ... ] }
command.called? #=> true

# - or -

command = SearchMovies.call('Toy Story')
command.called? #=> true
command.call    #=> { 'fingerprint_1' => [ 'Toy Story 1', ... ] }

# - or -

# Useful when you are not using the Errors mixin as its a one time access call.
# Very similar to the simple command builder.
SearchMovies.execute('Toy Story') #=> { 'fingerprint_1' => [ 'Toy Story 1', ... ] }
```

**Result**

```ruby
command = SearchMovies.new('Toy Story')
command.result  #=> nil

command.call    #=> { 'fingerprint_1' => [ 'Toy Story 1', ... ] }
command.result  #=> { 'fingerprint_1' => [ 'Toy Story 1', ... ] }

command.recall! #=> Clears the call, cache, errors, and then re-performs the call
command.result  #=> { 'fingerprint_2' => [ 'Toy Story 2', ... ] }
```

## Extensions

Extend complex base command with any of the following extensions:

### Errors (optional)

Learn more about using [Lite::Errors](https://github.com/drexed/lite-errors)

```ruby
class SearchMovies < Lite::Command::Complex
  include Lite::Command::Extensions::Errors

  # ... ommited ...

  private

  # Add a fingerprint error to the error pool
  def generate_fingerprint
    errors.add(:fingerprint, 'invalid md5 request value') if movies_by_name.nil?
    Digest::MD5.hexdigest(movies_by_name)
  rescue ArgumentError => e
    merge_exception!(e, key: :custom_key)
  end

end
```

**Callers**

```ruby
# Useful for controllers or actions that depend on states.
SearchMovies.perform('Toy Story') do |result, success, failure|
  success.call { redirect_to(movie_path, notice: "Movie can be found at: #{result}") }
  failure.call { redirect_to(root_path, notice: "Movie cannot be found at: #{result}") }
end
```

**Methods**

```ruby
command = SearchMovies.call('Toy Story')
command.errors    #=> Lite::Errors::Messages object

command.validate! #=> Raises Lite::Command::ValidationError if it has any errors
command.valid?    #=> Alias for validate!

command.errored?  #=> false
command.success?  #=> true
command.failure?  #=> Checks that it has been called and has errors
command.status    #=> :failure

command.result!   #=> Raises Lite::Command::ValidationError if it has any errors, if not it returns the result

# Use the following to merge errors from other commands or models
# with the default direction being `:from`
command.merge_errors!(command_2)
user_model.merge_errors!(command, direction: :to)
```

### Propagation (optional)

Propagation methods help you perform an action on an object. If successful is
returns the result else it adds the object errors to the form object. Available
propagation methods are:
`create_and_return!(object, params)`, `update_and_return!(object, params)`,
`save_and_return!(object)`, and `destroy_and_return!(object)`

```ruby
class SearchMovies < Lite::Command::Complex
  include Lite::Command::Extensions::Errors
  include Lite::Command::Extensions::Propagation

  # ... ommited ...

  def execute
    create_and_return!(User, name: 'John Doe')
  end

end
```

### Memoize (optional)

Learn more about using [Lite::Memoize](https://github.com/drexed/lite-memoize)

```ruby
class SearchMovies < Lite::Command::Complex
  include Lite::Command::Extensions::Memoize

  # ... ommited ...

  private

  # Sets the value in the cache
  # Subsequent method calls gets the cached value
  # This saves you the extra external HTTP.get call
  def movies_by_name
    cache.memoize { HTTP.get("http://movies.com?title=#{title}") }
  end

  # Gets the value in the cache
  def generate_fingerprint
    Digest::MD5.hexdigest(movies_by_name)
  end

end
```

**Methods**

```ruby
command = SearchMovies.call('Toy Story')
command.cache #=> Lite::Memoize::Instance object
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lite-command. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Lite::Command project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/lite-command/blob/master/CODE_OF_CONDUCT.md).
