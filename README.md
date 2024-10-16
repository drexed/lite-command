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

* [Configuration](#configuration)
* [Usage](#usage)
* [Execution](#execution)
  * [Dynamic Faults](#dynamic-faults)
* [Context](#context)
  * [Attributes](#attributes)
* [States](#states)
* [Statuses](#statuses)
* [Hooks](#hooks)
  * [State Hooks](#status-hooks)
  * [Attribute Hooks](#attribute-hooks)
  * [Execution Hooks](#execution-hooks)
  * [Status Hooks](#status-hooks)
* [Children](#children)
  * [Throwing Faults](#throwing-faults)
* [Sequences](#sequences)
* [Results](#results)
* [Examples](#examples)
  * [Disable Instance Calls](#disable-instance-calls)
* [Generator](#generator)

## Configuration

`rails g lite:command:install` will generate the following file in your application root:
`config/initalizers/lite_command.rb`

```ruby
Lite::Command.configure do |config|
  config.raise_dynamic_faults = true
end
```

## Usage

Defining a command is as simple as inheriting the base class and adding a `call` method
to a command object (required).

```ruby
class DecryptSecretMessage < Lite::Command::Base

  def call
    if invalid_magic_numbers?
      invalid!("Invalid crypto message")
    else
      context.decrypted_message = SecretMessage.decrypt(context.encrypted_message)
    end
  end

  private

  def invalid_magic_numbers?
    # Some logic...
  end

end
```

> [!TIP]
> You should treat all command as emphemeral objects, so you should think about making
> all of your domain logic private and leaving the default command API is exposed.

## Execution

Executing a command can be done as an instance or class call. It returns the command instance
in a frozen state. These will never call will never raise an execption, but will be kept track
of in its internal state.

```ruby
DecryptSecretMessage.call(...)
# - or -
DecryptSecretMessage.new(...).call

# On success, fault and exception:
#=> <DecryptSecretMessage ...>
```

> [!TIP]
> Class calls is the prefered format due to its readability. Read the [Disable Instance Calls](#disable-instance-calls)
> section on how to prevent instance style calls.

Commands can be called with a `!` bang method to raise a `Lite::Command::Fault` or the
original `StandardError` based exceptions.

```ruby
DecryptSecretMessage.call!(...)
# - or -
DecryptSecretMessage.new(...).call!

# On success:
#=> <DecryptSecretMessage ...>

# On fault:
#=> raises Lite::Command::Fault

# On exception:
#=> raises StandardError
```

### Dynamic Faults

Enable dynamic faults named after your command which is especially helpful for
catching + running custom logic or filtering out specific exceptions from your
APM service.

```ruby
class DecryptSecretMessage < Lite::Command::Base

  def call
    fail!("Some failure")
  end

  private

  def raise_dynamic_faults?
    true
  end

end

DecryptSecretMessage.call!(...)
#=> raises DecryptSecretMessage::Failure
```

## Context

Accessing the call arguments can be done through its internal context.
It can be used as internal storage to be accessed by it self and any
of its children commands.

> [!NOTE]
> Attributes that do **NOT** exist on the context will return `nil`.

```ruby
class DecryptSecretMessage < Lite::Command::Base

  def call
    # `ctx` is an alias to `context`
    context.decrypted_message = SecretMessage.decrypt(ctx.encrypted_message)
  end

end

cmd = DecryptSecretMessage.call(encrypted_message: "a22j3nkenjk2ne2")
cmd.context.decrypted_message #=> "Hello World"
cmd.ctx.fake_message          #=> nil
```

### Attributes

Delegate methods for a cleaner command setup, type checking and
argument requirements. Setup a contract by using the `attribute`
method which automatically delegates to `context`.

| Options         | Values | Default | Description |
| --------------- | ------ | ------- | ----------- |
| `from`          | Symbol, String | `:context` | The object containing the attribute. |
| `types`, `type` | Symbol, String, Array, Proc | | The allowed class types of the attribute value. |
| `required`      | Symbol, String, Boolean, Proc, hash | `false` | The attribute must be passed to the context or delegatable (no matter the value). Pass `{ reject_nil: true }` to invalidate `nil` values. Pass `{ reject_empty: true }` to invalidate `nil` and `empty` values. |

> [!NOTE]
> If optioned with some similar to `filled: true, types: [String, NilClass]`
> then `NilClass` for the `types` option will be removed automatically.

```ruby
class DecryptSecretMessage < Lite::Command::Base

  attribute :remote_storage, required: { reject_nil: true }, types: RemoteStorage

  attribute :a, :b
  attribute :c, :d, from: :remote_storage, types: [Integer, Float]
  attribute :x, :y, from: :local_storage, required: { reject_empty: true }, if: :signed_in?

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
cmd = DecryptSecretMessage.call(a: 2, b: 2, remote_storage: rs)
cmd.status         #=> "success"
cmd.context.result #=> 6

# With invalid options:
cmd = DecryptSecretMessage.call
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
cmd = DecryptSecretMessage.call
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
class DecryptSecretMessage < Lite::Command::Base

  def call
    if context.encrypted_message.empty?
      noop!("No message to decrypt")
    elsif context.encrypted_message.start_with?("== womp")
      invalid!("Invalid message start value", i18n: "gb.invalid_start_value")
    elsif context.encrypted_message.algo?(OldAlgo)
      failure!("Unsafe encryption algo detected")
    else
      context.decrypted_message = SecretMessage.decrypt(ctx.encrypted_message)
    end
  rescue CryptoError => e
    Apm.report_error(e)
    error!("Failed decryption due to: #{e}")
  end

end

cmd = DecryptSecretMessage.call(encrypted_message: "2jk3hjeh2hj2jh")
cmd.status   #=> "invalid"
cmd.reason   #=> "Invalid message start value"
cmd.metadata #=> { i18n: "gb.invalid_start_value" }

cmd.success? #=> false
cmd.noop?    #=> false
cmd.invalid? #=> true
cmd.invalid?("Other reason") #=> false
cmd.failure? #=> false
cmd.error?   #=> false

# `success` or `noop`
cmd.ok?      #=> false
cmd.ok?("Other reason") #=> false

# NOT `success`
cmd.fault?   #=> true
cmd.fault?("Other reason") #=> false

# `invalid` or `failure` or `error`
cmd.bad?     #=> true
cmd.bad?("Other reason") #=> false
```

## Hooks

Use hooks to run arbituary code at transition points and on finalized internals.
The following is an example of the hooks called for a failed command with a
successful child command.

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

Define one or more callbacks that are called during transitions between states.

```ruby
class DecryptSecretMessage < Lite::Command::Base

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

### Attribute Hooks

Define before attribtue validation callbacks.

```ruby
class DecryptSecretMessage < Lite::Command::Base

  def call
    # ...
  end

  private

  def on_before_validation
    # eg: Normalize context data
  end

end
```

### Execution Hooks

Define before and after callbacks to call around execution.

```ruby
class DecryptSecretMessage < Lite::Command::Base

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
class DecryptSecretMessage < Lite::Command::Base

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

When building complex commands, its best that you pass the parents context to the
child command (unless neccessary) so that it gains automated indexing and the
parents `cmd_id`.

```ruby
class DecryptSecretMessage < Lite::Command::Base

  def call
    context.merge!(decryption_key: ENV["DECRYPT_KEY"])
    ValidateSecretMessage.call(context)
  end

end
```

### Throwing Faults

Throwing faults allows you to bubble up child faults up to the parent. Use it to create
branches within your logic and create clean tracing of your command results. You can use
`throw!` as a catch-all or any of the bang status method `failure!`. Any `reason` and
`metadata` will be bubbled up from the original fault.

```ruby
class DecryptSecretMessage < Lite::Command::Base

  def call
    context.merge!(decryption_key: ENV["DECRYPT_KEY"])
    cmd = ValidateSecretMessage.call(context)

    if cmd.invalid?("Invalid magic numbers")
      error!(cmd) # Manually throw a specific fault
    elsif command.fault?
      throw!(cmd) # Automatically throws a matching fault
    else
      context.decrypted_message = SecretMessage.decrypt(ctx.encrypted_message)
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

  requires :user

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

During any point in the lifecyle of a command, `to_hash` can be called to dump out
the current values. The `index` value is auto-incremented and the `cmd_id` is static
when its passed to child commands. This helps with debugging and logging.

```ruby
command = DecryptSecretMessage.call(...)
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
class DecryptSecretMessage < Lite::Command::Base

  private_class_method :new

  def call
    # ...
  end

end

DecryptSecretMessage.new(...).call
#=> raise NoMethodError
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
