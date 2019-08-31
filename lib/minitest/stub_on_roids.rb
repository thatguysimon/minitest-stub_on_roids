# frozen_string_literal: true

require "minitest/autorun"

class StubbedMethodArgsError < StandardError; end
class MethodAlreadyStubbedError < StandardError; end

module Minitest
  module StubOnRoids
    def stub_with_args(name, retval, expected_args = [])
      raise MethodAlreadyStubbedError, "Method :#{name} already stubbed" if respond_to? "__minitest_stub__#{name}"

      retval_with_args_assertion = lambda do |*actual_args|
        expected_args.zip(actual_args).each do |expected_arg, actual_arg|
          next if expected_arg == actual_arg

          raise StubbedMethodArgsError, "stubbed method :#{name} called on #{self} with unexpected arguments #{actual_args}"
        end

        retval
      end

      stub(name, retval_with_args_assertion) do
        yield
      end
    end

    def stub_and_expect(name, retval = nil, expected_args = [], times: 1, expectations: [])
      raise MethodAlreadyStubbedError, "Method :#{name} already stubbed" if respond_to? "__minitest_stub__#{name}"

      mock = Minitest::Mock.new

      if (!retval.nil? || expected_args.size.positive?) && expectations.size.positive?
        raise ArgumentError, "`retval` and `expected_args` arguments cannot be passed along with `expectations`"
      end

      if expectations.size.zero?
        times.times { mock.expect :call, retval, expected_args }
      else
        expectations.each do |expectation|
          %i[expected_args return_value].each { |k| raise ArgumentError, "Missing key #{k} in expectation definition" if expectation[k].nil? }

          expectation_times = expectation[:times] || 1
          expectation_times.times { mock.expect :call, expectation[:return_value], expectation[:expected_args] }
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
