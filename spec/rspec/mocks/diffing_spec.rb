require "spec_helper"

RSpec.describe "Diffs printed when arguments don't match" do
  it "does not print a diff when single arguments are mismatched" do
    d = double("double")
    expect(d).to receive(:foo).with("some string")
    expect {
      d.foo("this other string")
    }.to raise_error(RSpec::Mocks::MockExpectationError, "Double \"double\" received :foo with unexpected arguments\n  expected: (\"some string\")\n       got: (\"this other string\")")
    reset d
  end

  it "does not print a diff when multiple string arguments are mismatched" do
    d = double("double")
    expect(d).to receive(:foo).with("some string", "some other string")
    expect {
      d.foo("this other string", "a fourth string")
    }.to raise_error(RSpec::Mocks::MockExpectationError, "Double \"double\" received :foo with unexpected arguments\n  expected: (\"some string\", \"some other string\")\n       got: (\"this other string\", \"a fourth string\")")
    reset d
  end

  it "prints a diff with hash args" do
    allow(RSpec::Mocks.configuration).to receive(:color?).and_return(false)
    d = double("double")
    expect(d).to receive(:foo).with(:foo => :bar, :baz => :quz)
    expect {
      d.foo(:bad => :hash)
    }.to raise_error(RSpec::Mocks::MockExpectationError,  "Double \"double\" received :foo with unexpected arguments\n  expected: ({:foo=>:bar, :baz=>:quz})\n       got: ({:bad=>:hash}) \n@@ -1,2 +1,2 @@\n-[{:foo=>:bar, :baz=>:quz}]\n+[{:bad=>:hash}]\n")
    reset d
  end

  it "prints a diff with an expected hash arg and a non-hash actual arg" do
    allow(RSpec::Mocks.configuration).to receive(:color?).and_return(false)
    d = double("double")
    expect(d).to receive(:foo).with(:foo => :bar, :baz => :quz)
    expect {
      d.foo(Object.new)
    }.to raise_error(RSpec::Mocks::MockExpectationError,  /-\[{:foo=>:bar, :baz=>:quz}\].*\+\[#<Object.*>\]/m)
    reset d
  end

  it "prints a diff with array args" do
    allow(RSpec::Mocks.configuration).to receive(:color?).and_return(false)
    d = double("double")
    expect(d).to receive(:foo).with([:a, :b, :c])
    expect {
      d.foo([])
    }.to raise_error(RSpec::Mocks::MockExpectationError,  "Double \"double\" received :foo with unexpected arguments\n  expected: ([:a, :b, :c])\n       got: ([]) \n@@ -1,2 +1,2 @@\n-[[:a, :b, :c]]\n+[[]]\n")
    reset d
  end
end
