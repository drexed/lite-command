# Lite::Command

[![Gem Version](https://badge.fury.io/rb/lite-command.svg)](http://badge.fury.io/rb/lite-command)
[![Build Status](https://travis-ci.org/drexed/lite-command.svg?branch=master)](https://travis-ci.org/drexed/lite-command)

Lite::Command provides an API for building simple and complex command based service objects.

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
* [Execution](#execution)
* [Context](#context)
* [Internals](#Internals)
* [Generator](#generator)

## Setup

Defining a command is as simple as adding a call method.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    # TODO: implement calculator
  end

end
```

## Execution

Executing a command can be done as an instance or class call.
It returns the command instance in a forzen state.
These will never call will never raise an execption, but will
be kept track of in its internal state.

**NOTE:** Class calls is the prefered format due to its readability.

```ruby
# Class call
CalculatePower.call(..args)

# Instance call
caculator = CalculatePower.new(..args).call

#=> <CalculatePower ...>
```

Commands can be called with a `!` bang method to raise a
`Lite::Command::Fault` based exception or the original
`StandardError` based exception.

```ruby
CalculatePower.call!(..args)
#=> raises Lite::Command::Fault
```

## Context

Accessing the call arguments can be done through its internal context.
It can be used as internal storage to be accessed by it self and any
of its children commands.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    context.result = context.a ** context.b
  end

end

command = CalculatePower.call(a: 2, b: 3)
command.context.result #=> 8
```

## Internals

#### States
State represents the state of the executable code. Once `execute`
is ran, it will always `complete` or `dnf` if a fault is thrown by a
child command.

- `pending`
    - Command objects that have been initialized.
- `executing`
    - Command objects actively executing code.
- `complete`
    - Command objects that executed to completion.
- `dnf`
    - Command objects that could NOT be executed to completion.
      This could be as a result of a fault/exception on the
      object itself or one of its children.

#### Statuses

Status represents the state of the callable code. If no fault
is thrown then a status of `success` is returned even if `call`
has not been executed. The list of status include (by severity):

- `success`
    - No fault or exception
- `noop`
    - Noop represents skipping completion of call execution early
      an unsatisfied condition or logic check where there is no
      point on proceeding.
    - **eg:** account is sample: skip since its a non-alterable record
- `invalid`
    - Invalid represents a stoppage of call execution due to
      missing, bad, or corrupt data.
    - **eg:** user not found: stop since rest of the call cant be executed
- `failure`
    - Failure represents a stoppage of call execution due to
      an unsatisfied condition or logic check where it blocks
      proceeding any further.
    - **eg:** record not found: stop since there is nothing todo
- `error`
    - Error represents a caught exception for a call execution
      that could not complete.
    - **eg:** ApiServerError: stop since there was a 3rd party issue

## Generator

`rails g command NAME` will generate the following file:

```erb
app/commands/[NAME]_command.rb
```

If a `ApplicationCommand` file in the `app/commands` directory is available, the
generator will create file that inherit from `ApplicationCommand` if not it will
fallback to `Lite::Command::Base`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lite-command. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Lite::Command project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/lite-command/blob/master/CODE_OF_CONDUCT.md).
