require "minitest/stub_on_roids"
require "minitest/spec"

class Banana
  def initialize(weight, color); end
  def peel(speed); end
end

describe Minitest::StubOnRoids do
  Banana.extend Minitest::StubOnRoids

  let(:banana_mock) do
    "banana"
  end

  let(:banana_mock2) do
    "banana2"
  end

  let(:banana_mock3) do
    "banana2"
  end
  describe ".stub_with_args" do
    describe "when a stubbed method is called with all expected args" do
      it "works like a charm" do
        Banana.stub_with_args(:new, banana_mock, [3.0, "Yellow"]) do
          assert_equal banana_mock, Banana.new(3.0, "Yellow")
        end
      end
    end

    describe "when a method is stubbed more than once" do
      it "raises MethodAlreadyStubbedError" do
        assert_raises MethodAlreadyStubbedError do
          Banana.stub_with_args(:new, banana_mock, [3.0, "Yellow"]) do
            Banana.stub_with_args(:new, banana_mock, [3.0, "Green"]) do
              # Some block here...
            end
          end
        end
      end
    end

    describe "when a stubbed method is called with unexpected args" do
      it "raises a StubbedMethodArgsError" do
        assert_raises StubbedMethodArgsError do
          Banana.stub_with_args(:new, banana_mock, [3.0, "Green"]) do
            Banana.new(3.0, "Yellow")
          end
        end
      end
    end
  end

  describe ".stub_and_expect" do
    describe "when a stubbed method is called the same amount of times it is expected" do
      it "works like a charm" do
        Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"], times: 3) do
          assert_equal banana_mock, Banana.new(3.0, "Yellow")
          assert_equal banana_mock, Banana.new(3.0, "Yellow")
          assert_equal banana_mock, Banana.new(3.0, "Yellow")
        end
      end
    end

    describe "when a method is stubbed more than once" do
      it "raises MethodAlreadyStubbedError" do
        assert_raises MethodAlreadyStubbedError do
          Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"]) do
            Banana.stub_and_expect(:new, banana_mock, [3.0, "Green"]) do
              # Some block here...
            end
          end
        end
      end
    end

    describe "a stubbed method is called more times than expected" do
      it "raises MockExpectationError" do
        assert_raises MockExpectationError do
          Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"], times: 1) do
            Banana.new(3.0, "Yellow")
            assert_equal banana_mock, Banana.new(3.0, "Yellow")
          end
        end
      end
    end

    describe "a stubbed method is called less times than expected" do
      it "raises MockExpectationError" do
        assert_raises MockExpectationError do
          Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"], times: 10) do
            assert_equal banana_mock, Banana.new(3.0, "Yellow")
          end
        end
      end
    end

    describe "when a stubbed method is expectedly called without args" do
      it "works like a charm" do
        Banana.stub_and_expect(:new, banana_mock) do
          assert_equal banana_mock, Banana.new
        end
      end
    end

    describe "when a stubbed method is called with the right amount but unexpected arguments" do
      it "raises an MockExpectationError" do
        assert_raises MockExpectationError do
          Banana.stub_and_expect(:new, banana_mock, [5.0, "Yellow"]) do
            assert_equal(banana_mock, Banana.new(14.0, "Green"))
          end
        end
      end
    end

    describe "a method is called with an unexpected amount of args" do
      it "raises an ArgumentError" do
        assert_raises ArgumentError do
          Banana.stub_and_expect(:new, banana_mock, [3.0]) do
            Banana.new
          end
        end
      end
    end

    describe "a method is called with different expectations in the right order" do
      it "works like a charm" do
        expectations = [
          { 
            expected_args: [3.0, "Yellow"],
            returned_value: banana_mock 
          },
          { 
            expected_args: [5.0, "Green"], 
            returned_value: banana_mock2 
          },
          { 
            expected_args: [15.0, "Red"], 
            returned_value: banana_mock3 
          }
        ]
        Banana.stub_and_expect(:new, banana_mock, expectations: expectations) do
          assert_equal(banana_mock, Banana.new(3.0, "Yellow"))
          assert_equal(banana_mock2, Banana.new(5.0, "Green"))
          assert_equal(banana_mock3, Banana.new(15.0, "Red"))
        end
      end
    end

    describe "a method is called with expectations missing expected_args key" do
      it "raises an ArgumentError" do
        assert_raises ArgumentError do
          expectations = [{ returned_value: banana_mock }]
          Banana.stub_and_expect(:new, banana_mock, expectations: expectations) do
            Banana.new
          end
        end
      end
    end

    describe "a method is called with expectations missing returned_value key" do
      it "raises an ArgumentError" do
        assert_raises ArgumentError do
          expectations = [{ expected_args: [3.0, "Yellow"] }]
          Banana.stub_and_expect(:new, banana_mock, expectations: expectations) do
            Banana.new
          end
        end
      end
    end

    describe "a method is called with different expectations with unexpected arguments" do
      it "raises an MockExpectationError" do
        assert_raises MockExpectationError do
          expectations = [
            { 
              expected_args: [3.0, "Yellow"],
              returned_value: banana_mock 
            },
            { 
              expected_args: [5.0, "Green"], 
              returned_value: banana_mock2 
            },
            { 
              expected_args: [15.0, "Red"], 
              returned_value: banana_mock3 
            }
          ]
          Banana.stub_and_expect(:new, banana_mock, expectations: expectations) do
            assert_equal(banana_mock, Banana.new(3.0, "Yellow"))
            assert_equal(banana_mock3, Banana.new(15.0, "Red"))
          end
        end
      end
    end
  end
end