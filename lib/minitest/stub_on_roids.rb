# frozen_string_literal: true

require "minitest/autorun"

class StubbedMethodArgsError < StandardError
  def initialize(method_name, klass, actual_args)
    super "Stubbed method :#{method_name} called on #{klass} with " \
          "unexpected arguments #{actual_args}"
  end
end

class MethodAlreadyStubbedError < StandardError
  def initialize(name)
    super "Method :#{name} already stubbed"
  end
end

module Minitest
  module StubOnRoids
    def stub_with_args(method_name, retval, expected_args = [])
      raise_if_already_stubbed(method_name)

      retval_with_args_assertion = lambda do |*actual_args|
        expected_args.zip(actual_args).each do |expected_arg, actual_arg|
          next if expected_arg == actual_arg

          raise StubbedMethodArgsError.new(method_name, self, actual_args)
        end

        retval
      end

      stub(method_name, retval_with_args_assertion) do
        yield
      end
    end

    def stub_and_expect(method_name, retval = nil, expected_args = [],
                        times: 1, expectations: [])
      raise_if_bad_args(retval, expected_args, expectations)
      raise_if_already_stubbed(method_name)

      mock = build_mock(retval, expected_args, times, expectations)

      stub(method_name, mock) do
        yield
      end

      mock.verify
    rescue StandardError => e
      # Monkeypatching the error message for better readability
      raise e.class, e.message.gsub(":call", ":#{name}")
    end

    private

    def build_mock(retval, expected_args, times, expectations)
      mock = Minitest::Mock.new

      if expectations.size.zero?
        times.times { mock.expect :call, retval, expected_args }
      else
        expectations.each do |expectation|
          validate_expectation(expectation)
          expectation_times = expectation[:times] || 1

          expectation_times.times do
            mock.expect :call, expectation[:return_value], expectation[:expected_args]
          end
        end
      end

      mock
    end

    def raise_if_already_stubbed(method_name)
      return unless respond_to? "__minitest_stub__#{method_name}"

      raise MethodAlreadyStubbedError, method_name
    end

    def raise_if_bad_args(retval, expected_args, expectations)
      if (!retval.nil? || expected_args.size.positive?) &&
         expectations.size.positive?
        raise ArgumentError,
              "`retval` and `expected_args` arguments cannot be passed along with `expectations`"
      end
    end

    def validate_expectation(expectation)
      %i[expected_args return_value].each do |k|
        raise ArgumentError, "Missing key #{k} in expectation definition" if expectation[k].nil?
      end
    end
  end
end
