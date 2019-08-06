require "minitest/autorun"

class StubbedMethodArgsError < StandardError; end
class MethodAlreadyStubbedError < StandardError; end

module Minitest
  module StubOnRoids
    def stub_with_args(name, val_or_callable, expected_args, &block)
      raise MethodAlreadyStubbedError, "Method :#{name} already stubbed" if self.respond_to? "__minitest_stub__#{name}"

      asserted_callable = lambda do |*actual_args|
        expected_args.zip(actual_args).each do |expected_arg, actual_arg|
          next if expected_arg == actual_arg
          raise StubbedMethodArgsError, "stubbed method :#{name} called on #{self} with unexpected arguments #{actual_args}"
        end
        
        val_or_callable
      end

      stub(name, asserted_callable) do
        yield
      end
    end

    def stub_and_expect(name, val_or_callable = nil, expected_args = [], times: 1)
      raise MethodAlreadyStubbedError, "Method :#{name} already stubbed" if self.respond_to? "__minitest_stub__#{name}"
      
      mock = Minitest::Mock.new
      times.times { mock.expect :call, val_or_callable, expected_args }

      stub(name, mock) do
        yield
      end

      mock.verify
    rescue StandardError => e
      # Monkeypatching the error message for better readability
      raise e.class, e.message.gsub(":call", ":#{name}")
    end
  end
end
