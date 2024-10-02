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
* [Statuses](#statuses)
* [Callbacks](#callbacks)
* [States](#states)
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
It returns the command instance in a frozen state.
These will never call will never raise an execption, but will
be kept track of in its internal state.

**NOTE:** Class calls is the prefered format due to its readability.

```ruby
# Class call
CalculatePower.call(...)

# Instance call
caculator = CalculatePower.new(...).call

#=> <CalculatePower ...>
```

Commands can be called with a `!` bang method to raise a
`Lite::Command::Fault` based exception or the original
`StandardError` based exception.

```ruby
CalculatePower.call!(...)
#=> raises Lite::Command::Fault
```

## Context

Accessing the call arguments can be done through its internal context.
It can be used as internal storage to be accessed by it self and any
of its children commands.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    # `ctx` is an alias to `context`
    context.result = ctx.a ** ctx.b
  end

end

command = CalculatePower.call(a: 2, b: 3)
command.context.result #=> 8
```

## Statuses

Status represents the state of the domain logic executed via the `call` method.
A status of `success` is returned even if the command has **NOT** been executed.

| Status    | Description |
| --------- | ----------- |
| `success` | Call execution completed without fault/exception. |
| `noop`    | **Fault** to skip completion of call execution early for an unsatisfied condition where proceeding is pointless. |
| `invalid` | **Fault** to stop call execution due to missing, bad, or corrupt data. |
| `failure` | **Fault** to stop call execution due to an unsatisfied condition where it blocks proceeding any further. |
| `error`   | **Fault** to stop call execution due to a thrown `StandardError` based exception. |

**NOTE:** faults must be manually set in your domain logic via the available
their bang `!` methods, eg:

```ruby
class CalculatePower < Lite::Command::Base

  def call
    if ctx.a.nil? || ctx.b.nil?
      invalid!("An a and b parameter must be passed")
    elsif ctx.a < 1 || ctx.b < 1
      failure!("Parameters must be >= 1")
    elsif ctx.a == 1 || ctx.b == 1
      noop!("Anything to the power of 1 is 1")
    else
      ctx.result = ctx.a ** ctx.b
    end
  end

end

command = CalculatePower.call(a: 1, b: 3)
command.ctx.result   #=> nil
command.status       #=> "noop"
command.noop?        #=> true
command.noop?("idk") #=> false
command.reason       #=> "Anything to the power of 1 is 1"
```

## Callbacks

Define `on_before_execution` and `on_after_execution` callbacks to execute
arbituary code before and after execution.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    # ...
  end

  private

  def on_after_execution
    CalculatorResult.create(name: "Power calculated", result: ctx.result)
  end

end
```

Define callbacks that are executed when a fault/exception occurs.
Available fault callbacks are `on_noop`, `on_invalid`, `on_failure`, and `on_error`.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    # ...
  end

  private

  def on_failure(_fault)
    ctx.user.rollback!
  end

  def on_error(e)
    APM.report_error(e)
  end

end
```

## States
`state` represents the condition of all the code command should execute.

| Status        | Description |
| ------------- | ----------- |
| `pending`     | Command objects that have been initialized. |
| `executing`   | Command objects that are actively executing code. |
| `complete`    | Command objects that executed to completion without fault/exception. |
| `interrupted` | Command objects that could **NOT** be executed to completion due to a fault/exception. |

**NOTE:** states are automatically set and can only be read via methods like
`executing?` but not altered directly, eg:

```ruby
class CalculatePower < Lite::Command::Base

  def call
    # ...
  end

end

command = CalculatePower.call(a: 1, b: 3)
command.state    #=> "executed"
command.pending? #=> false
```

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
