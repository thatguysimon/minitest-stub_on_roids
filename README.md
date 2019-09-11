# Minitest::StubOnRoids

Provides a set of helper methods around Minitest's `Object#stub` method.

The following methods are available:

* `.stub_with_args`
  1. Stubs a class method for the duration of the block.
  2. *If* the method is called, asserts that it is called with the expected arguments.
  3. Doesn't mind how many times the method is called, if at all.
* `.stub_and_expect`
  1. Stubs a class method for the duration of the block.
  2. Asserts that the method is called the exact amount of times as expected, and with the expected arguments.


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

### `.stub_with_args`

Use `.stub_with_args` to stub a class method as you normally would but also assert that if it is called - it is called with the expected arguments:

```ruby
Banana.stub_with_args(:new, banana_mock, [3.0, "Yellow"]) do
  Banana.new(3.0, "Yellow")
end

# :new is stubbed and `banana_mock` is returned instead

Banana.stub_with_args(:new, banana_mock, [3.0, "Green"]) do
  Banana.new(3.0, "Yellow")
end

# A StubbedMethodArgsError is raised because :new was called with the wrong arguments
```

Just like with Minitest's `Object#stub` method, there is no expectation on the amount of times the stubbed method is called in the block.

### `.stub_and_expect`

Use `.stub_and_expect` to stub a class method as you normally would but also set expectations on it, similarly to using `Minitest::Mock#expect`.

This means that a `MockExpectationError` will be raised if within the block...
* The method is called with a different set of arguments than expected.
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

#### Multiple calls
Use the `times` keyword argument to expect a method to be called multiple times within the block (default is 1):

```ruby
Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"], times: 2) do
  Banana.new(3.0, "Yellow")
  Banana.new(3.0, "Yellow")
end

# => Works
```

#### Multiple calls with different arguments

Use the `expectations` keyword argument to expect a method to be called a multiple times within the block with different arguments and return values (order must be respected).

Given the following expectations array:

```ruby
expectations = [
  { 
    expected_args: [3.0, "Yellow"],
    return_value: banana_mock 
  },
  { 
    expected_args: [5.0, "Green"], 
    return_value: banana_mock2 
  },
  { 
    expected_args: [15.0, "Red"], 
    return_value: banana_mock3 
  }
]
```

Calling `Banana.new` multiple times exactly as expected works:

```ruby
Banana.stub_and_expect(:new, expectations: expectations) do
  Banana.new(3.0, "Yellow")
  Banana.new(5.0, "Green")
  Banana.new(15.0, "Red")
end

# => Works
```

Calling `Banana.new` with the wrong arguments fails:

```ruby
Banana.stub_and_expect(:new, expectations: expectations) do
  Banana.new(3.0, "Yellow")
  Banana.new(15.0, "Red")
end

# => MockExpectationError raised
```

### Notes

* This gem might work with instance methods as well, but its intent is (and it's only tested for) using it on class methods.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thatguysimon/minitest-stub_on_roids. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](https://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
