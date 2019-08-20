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

    def stub_and_expect(name, val_or_callable = nil, expected_args = [], times: 1, expectations: [])
      raise MethodAlreadyStubbedError, "Method :#{name} already stubbed" if self.respond_to? "__minitest_stub__#{name}"
      
      mock = Minitest::Mock.new

      if (expected_args.size.positive? or !val_or_callable.nil?) && expectations.size.positive?
        raise ArgumentError, "Exclusion problem: expected_args and val_or_callable cant be sent with expectations"
      end

      if expectations.size.zero?
        times.times { mock.expect :call, val_or_callable, expected_args }
      else
        expectations.each do |expectation|
          [:expected_args, :return_value].each { |k| raise ArgumentError, "#{k} not found in expectation" if expectation[k].nil? }
          mock.expect :call, expectation[:return_value], expectation[:expected_args]
        end
      end

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
