# minitest-stub_on_roids

Provides a set of helper methods around Minitest's Object#stub method.

The following methods are available:

* `#stub_with_args`
  1. Stubs a class method.
  2. Asserts that it's called with the expected arguments.
  3. Doesn't mind how many times the method is called.
* `#stub_and_expect`
  1. Stubs a class method.
  2. Asserts that it's called with the expected arguments.
  3. Asserts that the method is called the exact amount of times as expected.

## Installation

Add this line to your application's Gemfile:

    gem "minitest-stub_on_roids"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minitest-stub_on_roids

## Usage

Require `minitest/stub_on_roids` in your test:

```ruby
require 'minitest/stub_on_roids'
```

Extend the class you want to stub methods of:

```ruby
Banana.extend Minitest::StubOnRoids
```

This will add the following methods to the class:

### `#stub_with_args`

Use `#stub_with_args` to stub a class method as you normally would but also assert that it is called with the expected arguments:

```ruby
# This will stub out the :new method and return `banana_mock` instead
Banana.stub_with_args(:new, banana_mock, [3.0, "Yellow"]) do
  Banana.new(3.0, "Yellow")
end

# This will raise a StubbedMethodArgsError because :new was called with the wrong arguments
Banana.stub_with_args(:new, banana_mock, [3.0, "Green"]) do
  Banana.new(3.0, "Yellow")
end
```

### `#stub_and_expect`

Use `#stub_and_expect` to stub a class method as you normally would but also set expectations on it, similarly to how you would do it with a regular `Minitest::Mock`.

This means that a `MockExpectationError` will be thrown if:
* The method is called no with a different set of arguments.
* The method is called more or less the amount of times it was expected to be called.

```ruby
Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"]) do
  # Not calling `Banana.new`
end

# => MockExpectationError raised
```

```ruby
Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"]) do
  Banana.new(3.0, "Yellow")
  Banana.new(3.0, "Yellow")
end

# => MockExpectationError raised
```

You can use the `times` keyword argument to expect a method to be called a specific amount of times within the block:

```ruby
Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"], times: 2) do
  Banana.new(3.0, "Yellow")
  Banana.new(3.0, "Yellow")
end

# => Works
```

### Limitations

* Nesting blocks is not supported, meaning you can't expect methods to be called with more than one set of arguments at a time.
* This gem might work with instance methods as well, but its intent is (and it's only tested only for) using it on class methods only.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thatguysimon/minitest-stub_on_roids. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
