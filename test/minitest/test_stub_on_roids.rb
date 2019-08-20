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
    "banana3"
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
        Banana.stub_with_args(:new, banana_mock, [3.0, "Green"]) do
          assert_raises StubbedMethodArgsError do
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
        Banana.stub_and_expect(:new, banana_mock, [3.0, "Yellow"], times: 1) do
          assert_equal banana_mock, Banana.new(3.0, "Yellow")
          assert_raises MockExpectationError do
            Banana.new(3.0, "Yellow")
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

    describe "when a stubbed method is called with unexpected args" do
      it "raises an MockExpectationError" do
        assert_raises MockExpectationError do
          Banana.stub_and_expect(:new, banana_mock, [5.0, "Yellow"]) do
            assert_equal banana_mock, Banana.new(14.0, "Green")
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

    describe "a method is called with multiple expectations in correct order" do
      it "works like a charm" do
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

        Banana.stub_and_expect(:new, expectations: expectations) do
          assert_equal(banana_mock, Banana.new(3.0, "Yellow"))
          assert_equal(banana_mock2, Banana.new(5.0, "Green"))
          assert_equal(banana_mock3, Banana.new(15.0, "Red"))
        end
      end
    end

    describe "a method is called with expectations missing expected_args key" do
      it "raises an ArgumentError" do
        assert_raises ArgumentError do
          expectations = [{ return_value: banana_mock }]
          Banana.stub_and_expect(:new, expectations: expectations)
        end
      end
    end

    describe "a method is called with expectations missing return_value key" do
      it "raises an ArgumentError" do
        assert_raises ArgumentError do
          expectations = [{ expected_args: [3.0, "Yellow"] }]
          Banana.stub_and_expect(:new, expectations: expectations)
        end
      end
    end

    describe "a method is called with different expectations with unexpected arguments" do
      it "raises an MockExpectationError" do
        assert_raises MockExpectationError do
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

          Banana.stub_and_expect(:new, expectations: expectations) do
            assert_equal banana_mock, Banana.new(3.0, "Yellow")
            assert_equal banana_mock3, Banana.new(15.0, "Red")
          end
        end
      end
    end

    describe "a method is called less times than expected" do
      it "raises an MockExpectationError" do
        assert_raises MockExpectationError do
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
          
          Banana.stub_and_expect(:new, expectations: expectations) do
            assert_equal banana_mock, Banana.new(3.0, "Yellow")
            assert_equal banana_mock2, Banana.new(5.0, "Green")
          end
        end
      end
    end

    describe "a method is called more times than expected" do
      it "raises an MockExpectationError" do
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
        
        Banana.stub_and_expect(:new, expectations: expectations) do
          assert_equal banana_mock, Banana.new(3.0, "Yellow")
          assert_equal banana_mock2, Banana.new(5.0, "Green")
          assert_equal banana_mock3, Banana.new(15.0, "Red")
          assert_raises MockExpectationError do
            Banana.new(5.0, "Purple")
          end
        end
      end
    end

    describe "a method is called with expected_args, val_or_callable and expectations" do
      it "raises an ArgumentError" do
        assert_raises ArgumentError do
          expectations = [
            { 
              expected_args: [3.0, "Yellow"],
              return_value: banana_mock 
            }
          ]
          
          expected_args = ['some_arg']

          Banana.stub_and_expect(:new, banana_mock, expected_args, expectations: expectations)
        end
      end
    end

    describe "a method is called with multiple expectations multiple times each in correct order" do
      it "works like a charm" do
        expectations = [
          { 
            expected_args: [3.0, "Yellow"],
            return_value: banana_mock,
            times: 2
          },
          { 
            expected_args: [5.0, "Green"], 
            return_value: banana_mock2,
            times: 2
          },
          { 
            expected_args: [15.0, "Red"], 
            return_value: banana_mock3 
          }
        ]

        Banana.stub_and_expect(:new, expectations: expectations) do
          assert_equal(banana_mock, Banana.new(3.0, "Yellow"))
          assert_equal(banana_mock, Banana.new(3.0, "Yellow"))
          assert_equal(banana_mock2, Banana.new(5.0, "Green"))
          assert_equal(banana_mock2, Banana.new(5.0, "Green"))
          assert_equal(banana_mock3, Banana.new(15.0, "Red"))
        end
      end
    end
  end
end