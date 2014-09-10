require "spec_helper"

RSpec.describe "Diffs printed when arguments don't match" do
  before do
    allow(RSpec::Mocks.configuration).to receive(:color?).and_return(false)
  end

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

  let(:expected_hash) { {:foo => :bar, :baz => :quz} }

  let(:actual_hash) { {:bad => :hash} }

  it "prints a diff with hash args" do
    d = double("double")
    expect(d).to receive(:foo).with(expected_hash)
    expect {
      d.foo(:bad => :hash)
    }.to raise_error(RSpec::Mocks::MockExpectationError,  "Double \"double\" received :foo with unexpected arguments\n  expected: (#{expected_hash.inspect})\n       got: (#{actual_hash.inspect}) \n@@ -1,2 +1,2 @@\n-[#{expected_hash.inspect}]\n+[#{actual_hash.inspect}]\n")
    reset d
  end

  it "prints a diff with an expected hash arg and a non-hash actual arg" do
    d = double("double")
    expect(d).to receive(:foo).with(expected_hash)
    expect {
      d.foo(Object.new)
    }.to raise_error(RSpec::Mocks::MockExpectationError,  /-\[#{Regexp.escape(expected_hash.inspect)}\].*\+\[#<Object.*>\]/m)
    reset d
  end

  it "prints a diff with array args" do
    d = double("double")
    expect(d).to receive(:foo).with([:a, :b, :c])
    expect {
      d.foo([])
    }.to raise_error(RSpec::Mocks::MockExpectationError,  "Double \"double\" received :foo with unexpected arguments\n  expected: ([:a, :b, :c])\n       got: ([]) \n@@ -1,2 +1,2 @@\n-[[:a, :b, :c]]\n+[[]]\n")
    reset d
  end

  it "does not use the object's description for a non-matcher object that implements #description" do
    d = double("double")

    collab = double(:collab, :description => "This string")
    collab_inspect = collab.inspect

    expect(d).to receive(:foo).with(collab)
    expect {
      d.foo([])
    }.to raise_error(RSpec::Mocks::MockExpectationError,  "Double \"double\" received :foo with unexpected arguments\n  expected: (#{collab_inspect})\n       got: ([]) \n@@ -1,2 +1,2 @@\n-[#{collab_inspect}]\n+[[]]\n")
    reset d
  end

  it "does use the object's description for a matcher object that implements #description" do
    d = double("double")

    collab = double(:collab, :description => "This string")
    allow(RSpec::Support).to receive(:is_a_matcher?).with(collab).and_return(true)
    collab_description = collab.description

    expect(d).to receive(:foo).with(collab)
    expect {
      d.foo([:a, :b])
    }.to raise_error(RSpec::Mocks::MockExpectationError,  "Double \"double\" received :foo with unexpected arguments\n  expected: (#{collab_description})\n       got: ([:a, :b]) \n@@ -1,2 +1,2 @@\n-[\"#{collab_description}\"]\n+[[:a, :b]]\n")
    reset d
  end

  it "does not use the object's description for a matcher object that does not implement #description" do
    d = double("double")

    collab = double(:collab)
    allow(RSpec::Support).to receive(:is_a_matcher?).with(collab).and_return(true)
    collab_inspect = collab.inspect

    expect(d).to receive(:foo).with(collab)
    expect {
      d.foo([:a, :b])
    }.to raise_error(RSpec::Mocks::MockExpectationError,  "Double \"double\" received :foo with unexpected arguments\n  expected: (#{collab_inspect})\n       got: ([:a, :b]) \n@@ -1,2 +1,2 @@\n-[#{collab_inspect}]\n+[[:a, :b]]\n")
    reset d
  end
end
