# minitest-stub_on_roids

Provides a set of helper methods and extensions for Minitest's Object#stub method.

The following features are available:

1. `#stub_with_args` - Assert that stubbed class methods are called with the expected arguments.
2. `#stub_and_expect` - Set expectations on stubbed class methods.

## Installation

Add this line to your application's Gemfile:

  gem "minitest-mock_expectations"

And then execute:

  $ bundle

Or install it yourself as:

  $ gem install minitest-mock_expectations

## Usage

### `#stub_with_args`

Use `#stub_with_args` to stub out class method calls but assert that they are called with the expected arguments:

```ruby
# This will work
Banana.stub_with_args(:new, banana_mock, [3.0, "Yellow"]) do
  Banana.new(3.0, "Yellow")
end

# This will raise a StubbedMethodArgsError
Banana.stub_with_args(:new, banana_mock, [3.0, "Green"]) do
  Banana.new(3.0, "Yellow")
end
```

### `#stub_and_expect`

Use `#stub_and_expect` to set expectations on a class method, similarly to how you would do it with a regular Minitest::Mock:

```ruby
# This will work
Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"]) do
  Banana.new(3.0, "Yellow")
end

# This will raise a MockExpectationError
Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"], times: 1) do
  Banana.new(3.0, "Yellow")
  Banana.new(3.0, "Yellow")
end
```

