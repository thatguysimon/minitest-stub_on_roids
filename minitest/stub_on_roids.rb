require "minitest/autorun"
require "byebug"


class StubbedMethodArgsError < StandardError; end

module Minitest
  module StubOnRoids
    def stub_with_args(name, val_or_callable, expected_args, &block)
      asserted_callable = lambda do |*actual_args|
        expected_args.zip(actual_args).each do |expected_arg, actual_arg|
          next if expected_arg == actual_arg
          raise StubbedMethodArgsError, "stubbed method :#{name} called on #{self} with unexpected arguments #{actual_args}"
        end
        
        val_or_callable
      end

      # Minitest"s Object#stub will call `asserted_callable` and return the result
      stub(name, asserted_callable) do
        yield
      end
    end

    def stub_and_expect(name, val_or_callable = nil, expected_args = [], times: 1)
      mock = Minitest::Mock.new
      times.times { mock.expect :call, val_or_callable, expected_args }

      stub(name, mock) do
        yield
      end

      mock.verify
    rescue StandardError => e
      raise e.class, e.message.gsub(":call", ":#{name}")
    end
  end
end

require "minitest/spec"

class Banana
  def initialize(weight, color); end
  def peel(speed); end
end

describe Minitest::StubOnRoids do
  Banana.extend Minitest::StubOnRoids

  let(:banana_mock) do
    mock = MiniTest::Mock.new
    mock.expect(:peel, "Peeling!", [10])
  end

  describe ".stub_with_args" do
    it "is called with expected args" do
      Banana.stub_with_args(:new, banana_mock, [3.0, "Yellow"]) do
        banana = Banana.new(3.0, "Yellow")
      end
    end

    it "raises StubbedMethodArgsError if a stubbed method is called with unexpected args" do
      assert_raises StubbedMethodArgsError do
        Banana.stub_with_args(:new, banana_mock, [3.0, "Green"]) do
          banana = Banana.new(3.0, "Yellow")
        end
      end
    end
  end

  describe ".stub_and_expect" do
    it "is called the same amount of times it is expected" do
      Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"], times: 3) do
        banana = Banana.new(3.0, "Yellow")
        banana = Banana.new(3.0, "Yellow")
        banana = Banana.new(3.0, "Yellow")
      end
    end

    it "raises MockExpectationError if a method is called more times than expected" do
      assert_raises MockExpectationError do
        Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"], times: 1) do
          banana = Banana.new(3.0, "Yellow")
          banana = Banana.new(3.0, "Yellow")
        end
      end
    end

    it "is expectedly called without args" do
      Banana.stub_and_expect(:new, banana_mock) do
        banana = Banana.new
      end
    end

    it "raises ArgumentError if a method is called with an unexpected amount of args" do
      assert_raises ArgumentError do
        Banana.stub_and_expect(:new, banana_mock, [3.0]) do
          banana = Banana.new
        end
      end
    end
  end
end
