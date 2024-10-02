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
  * [Dynamic Faults](#dynamic_faults)
* [Context](#context)
* [States](#states)
* [Statuses](#statuses)
* [Callbacks](#callbacks)
  * [State Hooks](#status_hooks)
  * [Execution Hooks](#execution_hooks)
  * [Status Hooks](#status_hooks)
* [Generator](#generator)

## Setup

Defining a command is as simple as adding a call method to a command object (required).

```ruby
class CalculatePower < Lite::Command::Base

  def call
    # TODO: implement calculator
  end

  private

  # Domain logic...

end
```

> [!TIP]
> You should make all of your domain logic private so that only the command API is exposed.

## Execution

Executing a command can be done as an instance or class call.
It returns the command instance in a frozen state.
These will never call will never raise an execption, but will
be kept track of in its internal state.

```ruby
# Class call
CalculatePower.call(...)

# Instance call
caculator = CalculatePower.new(...).call

#=> <CalculatePower ...>
```

> [!TIP]
> Class calls is the prefered format due to its readability.

Commands can be called with a `!` bang method to raise a
`Lite::Command::Fault` based exception or the original
`StandardError` based exception.

```ruby
CalculatePower.new(...).call!
CalculatePower.call!(...)
#=> raises Lite::Command::Fault
```

### Dynamic Faults

You can enable dynamic faults named after your command. This is
especially helpful for catching + running custom logic or filtering
out specific errors from you APM service.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    # ...
  end

  private

  def raise_dynamic_faults?
    true
  end

end

CalculatePower.call!(...)
#=> raises CalculatePower::Fault
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

## States
`state` represents the condition of all the code command should execute.

| Status        | Description |
| ------------- | ----------- |
| `pending`     | Command objects that have been initialized. |
| `executing`   | Command objects that are actively executing code. |
| `complete`    | Command objects that executed to completion without fault/exception. |
| `interrupted` | Command objects that could **NOT** be executed to completion due to a fault/exception. |

> [!CAUTION]
> States are automatically transitioned and should NEVER be altered manually.

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

> [!IMPORTANT]
> Faults must be manually set in your domain logic via the available their bang `!` methods.

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
  rescue DivisionError => e
    error!("Cathcing it myself")
  end

end

command = CalculatePower.call(a: 1, b: 3)
command.ctx.result   #=> nil
command.status       #=> "noop"
command.noop?        #=> true
command.noop?("idk") #=> false
command.reason       #=> "Anything to the power of 1 is 1"
```

> [!NOTE]
> There is no `success!` method as its the default status.

## Callbacks

Use callbacks to run arbituary code at transition points and
on finalized internals. The following is an example of the hooks
called for a failed command with a successful child command.

```ruby
-> 1. FooCommand.on_pending
-> 2. FooCommand.on_before_execution
-> 3. FooCommand.on_executing
  -> 3a. BarCommand.on_pending
  -> 3b. BarCommand.on_before_execution
  -> 3c. BarCommand.on_executing
  -> 3d. BarCommand.on_after_execution
  -> 3e. BarCommand.on_success
  -> 3f. BarCommand.on_complete
-> 4. FooCommand.on_after_execution
-> 5. FooCommand.on_failure
-> 6. FooCommand.on_interrupted
```

### Status Hooks

Define one or more callbacks that are called during transitions
between states.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    # ...
  end

  private

  def on_pending
    # eg: Append additional contextual data
  end

  def on_executing
    # eg: Insert inspection debugger
  end

  def on_complete
    # eg: Log message for posterity
  end

  def on_interrupted
    # eg: Report to APM with tags and metadata
  end

end
```

### Execution Hooks

Define before and after callbacks to call around execution.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    # ...
  end

  private

  def on_before_execution
    # eg: Append additional contextual data
  end

  def on_after_execution
    # eg: Store results to database
  end

end
```

### Status Hooks

Define one or more callbacks that are called after execution for
specific statuses.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    # ...
  end

  private

  def on_success
    # eg: Increment KPI counter
  end

  def on_noop(fault)
    # eg: Log message for posterity
  end

  def on_invalid(fault)
    # eg: Send metadata errors to frontend
  end

  def on_failure(fault)
    # eg: Rollback record changes
  end

  def on_error(fault_or_exception)
    # eg: Report to APM with tags and metadata
  end

end
```

> [!NOTE]
> The `on_success` callback does **NOT** take any arguments.

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
