# Lite::Command

[![Gem Version](https://badge.fury.io/rb/lite-command.svg)](http://badge.fury.io/rb/lite-command)

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
  * [Dynamic Faults](#dynamic-faults)
* [Context](#context)
  * [Attributes](#attributes)
* [States](#states)
* [Statuses](#statuses)
* [Callbacks](#callbacks)
  * [State Hooks](#status-hooks)
  * [Execution Hooks](#execution-hooks)
  * [Status Hooks](#status-hooks)
* [Children](#children)
  * [Throwing Faults](#throwing-faults)
* [Sequences](#sequences)
* [Results](#results)
* [Examples](#examples)
  * [Disable Instance Calls](#disable-instance-calls)
  * [ActiveModel Validations](#activemodel-validations)
* [Generator](#generator)

## Setup

Defining a command is as simple as inheriting the base class and
adding a `call` method to a command object (required).

```ruby
class CalculatePower < Lite::Command::Base

  def call
    if all_even_numbers?
      context.result = ctx.a ** ctx.b
    else
      invalid!("All values must be even")
    end
  end

  private

  def all_even_numbers?
    # Some logic...
  end

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
CalculatePower.call(...)
# - or -
CalculatePower.new(...).call

# On success, fault and exception:
#=> <CalculatePower ...>
```

> [!TIP]
> Class calls is the prefered format due to its readability.

Commands can be called with a `!` bang method to raise a
`Lite::Command::Fault` based exception or the original
`StandardError` based exception.

```ruby
CalculatePower.call!(...)
# - or -
CalculatePower.new(...).call!

# On success:
#=> <CalculatePower ...>

# On fault:
#=> raises Lite::Command::Fault

# On exception:
#=> raises StandardError
```

### Dynamic Faults

You can enable dynamic faults named after your command. This is
especially helpful for catching + running custom logic or filtering
out specific errors from you APM service.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    fail!("Some failure")
  end

  private

  def raise_dynamic_faults?
    true
  end

end

CalculatePower.call!(...)
#=> raises CalculatePower::Failure
```

## Context

Accessing the call arguments can be done through its internal context.
It can be used as internal storage to be accessed by it self and any
of its children commands.

> [!NOTE]
> Attributes that do **NOT** exist on the context will return `nil`.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    # `ctx` is an alias to `context`
    context.result = ctx.a ** ctx.b
  end

end

cmd = CalculatePower.call(a: 2, b: 3)
cmd.context.result #=> 8
cmd.ctx.fake       #=> nil
```

### Attributes

Delegate methods for a cleaner command setup, type checking and
argument requirements. Setup a contract by using the `attribute`
method which automatically delegates to `context`.

| Options         | Values | Default | Description |
| --------------- | ------ | ------- | ----------- |
| `from`          | Symbol, String | `:context` | The object containing the attribute. |
| `types`, `type` | Symbol, String, Array, Proc | | The allowed class types of the attribute value. |
| `required`      | Symbol, String, Boolean, Proc | `false` | The attribute must be passed to the context or delegatable (no matter the value). |
| `filled`        | Symbol, String, Boolean, Proc, Hash | `false` | The attribute value must be not be `nil`. Prevent empty values using `{ empty: false }` |

> [!NOTE]
> If optioned with some similar to `filled: true, types: [String, NilClass]`
> then `NilClass` for the `types` option will be removed automatically.

```ruby
class CalculatePower < Lite::Command::Base

  attribute :remote_storage, required: true, filled: true, types: RemoteStorage

  attribute :a, :b
  attribute :c, :d, from: :remote_storage, types: [Integer, Float]
  attribute :x, :y, from: :local_storage, filled: { empty: false }, if: :signed_in?

  def call
    context.result =
      (a.to_i ** b.to_i) +
      (c.to_i + d.to_i) -
      (x.to_i + y.to_i)
  end

  private

  def local_storage
    @local_storage ||= LocalStorage.new(x: 1, y: 1, z: 99)
  end

  def signed_in?
    ctx.user.signed_in?
  end

end

# With valid options:
rs  = RemoteStorage.new(c: 2, d: 2, j: 99)
cmd = CalculatePower.call(a: 2, b: 2, remote_storage: rs)
cmd.status         #=> "success"
cmd.context.result #=> 6

# With invalid options:
cmd = CalculatePower.call
cmd.status   #=> "invalid"
cmd.reason   #=> "Invalid context attributes"
cmd.metadata #=> {
             #=>   context: ["a is required", "remote_storage must be filled"],
             #=>   remote_storage: ["d type invalid"]
             #=>   local_storage: ["is not defined or an attribute"]
             #=> }
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
> States are automatically transitioned and should **NEVER** be altered manually.

```ruby
cmd = CalculatePower.call
cmd.state        #=> "complete"

cmd.pending?     #=> false
cmd.executing?   #=> false
cmd.complete?    #=> true
cmd.interrupted? #=> false

# `complete` or `interrupted`
cmd.executed?
```

## Statuses

`status` represents the state of the domain logic executed via the `call` method.
A status of `success` is returned even if the command has **NOT** been executed.

| Status    | Description |
| --------- | ----------- |
| `success` | Call execution completed without fault/exception. |
| `noop`    | **Fault** to skip completion of call execution early for an unsatisfied condition where proceeding is pointless. |
| `invalid` | **Fault** to stop call execution due to missing, bad, or corrupt data. |
| `failure` | **Fault** to stop call execution due to an unsatisfied condition where it blocks proceeding any further. |
| `error`   | **Fault** to stop call execution due to a thrown `StandardError` based exception. |

> [!IMPORTANT]
> Each **fault** status has a setter method ending in `!` that invokes a matching fault procedure.
> Metadata may also be passed to enrich your fault response.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    if ctx.a.nil? || ctx.b.nil?
      invalid!("An a and b parameter must be passed")
    elsif ctx.a < 1 || ctx.b < 1
      failure!("Parameters must be >= 1")
    elsif ctx.a == 1 || ctx.b == 1
      noop!(
        "Anything to the power of 1 is 1",
        { i18n: "some.key" }
      )
    else
      ctx.result = ctx.a ** ctx.b
    end
  rescue DivisionError => e
    error!("Cathcing it myself")
  end

end

cmd = CalculatePower.call(a: 1, b: 3)
cmd.status   #=> "noop"
cmd.reason   #=> "Anything to the power of 1 is 1"
cmd.metadata #=> { i18n: "some.key" }

cmd.success? #=> false
cmd.noop?    #=> true
cmd.noop?("Other reason") #=> false
cmd.invalid? #=> false
cmd.failure? #=> false
cmd.error?   #=> false

# `success` or `noop`
cmd.ok?      #=> true
cmd.ok?("Other reason") #=> false

# NOT `success`
cmd.fault?   #=> true
cmd.fault?("Other reason") #=> false

# `invalid` or `failure` or `error`
cmd.bad?     #=> false
cmd.bad?("Other reason") #=> false
```

## Callbacks

Use callbacks to run arbituary code at transition points and
on finalized internals. The following is an example of the hooks
called for a failed command with a successful child command.

```ruby
-> 1. FooCommand.on_pending
-> 2. FooCommand.on_before_execution
-> 3. FooCommand.on_executing
---> 3a. BarCommand.on_pending
---> 3b. BarCommand.on_before_execution
---> 3c. BarCommand.on_executing
---> 3d. BarCommand.on_after_execution
---> 3e. BarCommand.on_success
---> 3f. BarCommand.on_complete
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

## Children

When building complex commands, its best that you pass the
parents context to the child command (unless neccessary) so
that it gains automated indexing and the parents `cmd_id`.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    context.merge!(some_other: "required value")
    CalculateSqrt.call(context)
  end

end
```

### Throwing Faults

Throwing faults allows you to bubble up child faults up to the parent.
Use it to create branches within your logic and create clean tracing
of your command results. You can use `throw!` as a catch-all or any
of the bang status method `failure!`. Any `reason` and `metadata` will
be bubbled up from the original fault.

```ruby
class CalculatePower < Lite::Command::Base

  def call
    command = CalculateSqrt.call(context.merge!(some_other: "required value"))

    if command.noop?("Sqrt of 1 is 1")
      # Manually throw a specific fault
      invalid!(command)
    elsif command.fault?
      # Automatically throws a matching fault
      throw!(command)
    else
      # Success, do nothing
    end
  end

end
```

## Sequences

A sequence is a command that calls commands in a linear fashion.
This is useful for composing multiple steps into one call.

> [!NOTE]
> Sequences only stop processing on `invalid`, `failure`, and `error`
> faults. This is due to the the idea the `noop` performs no work,
> so its no different than just passing the context forward. To change
> this behavior, just override the `ok?` method with you logic, eg: just `success`

> [!WARNING]
> Do **NOT** define a call method in this class. The sequence logic is
> automatically defined by the sequence class.

```ruby
class ProcessCheckout < Lite::Command::Sequence

  attribute :user, required: true, filled: true

  step FinalizeInvoice
  step ChargeCard, if: :card_available?
  step SendConfirmationEmail, SendConfirmationText
  step NotifyWarehouse, unless: proc { ctx.invoice.fullfilled_by_amazon? }

  # Do NOT define a call method.

  private

  def card_available?
    user.has_card?
  end

end

seq = ProcessCheckout.call(...)
# <ProcessCheckout ...>
```

## Results

During any point in the lifecyle of a command, `to_hash` can be
called to dump out the current values. The `index` value is
auto-incremented and the `cmd_id` is static when its passed to
child commands. This helps with debugging and logging.

```ruby
command = CalculatePower.call(...)
command.to_hash #=> {
                #=>   index: 1,
                #=>   cmd_id: "018c2b95-b764-7615-a924-cc5b910ed1e5",
                #=>   command: "FailureCommand",
                #=>   outcome: "failure",
                #=>   state: "interrupted",
                #=>   status: "failure",
                #=>   reason: "[!] command stopped due to failure",
                #=>   metadata: {
                #=>     errors: { name: ["is too short"] },
                #=>     i18n_key: "command.failure"
                #=>   },
                #=>   caused_by: 1,
                #=>   thrown_by: 1,
                #=>   runtime: 0.0123
                #=> }
```

## Examples

### Disable Instance Calls

```ruby
class CalculatePower < Lite::Command::Base

  private_class_method :new

  def call
    # ...
  end

end

CalculatePower.new(...).call
#=> raise NoMethodError
```

### ActiveModel Validations

```ruby
class CalculatePower < Lite::Command::Base
  include ActiveModel::Validations

  validates :a, :b, presence: true

  def call
    # ...
  end

  def read_attribute_for_validation(key)
    context.public_send(key)
  end

  private

  def on_before_execution
    return if valid?

    invalid!(
      errors.full_messages.to_sentence,
      errors.to_hash
    )
  end

end

CalculatePower.call!

# With `validate!`
#=> raise ActiveRecord::RecordInvalid

# With `valid?`
#=> raise Lite::Command::Invalid
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
