require 'spec_helper'
require 'diffident/lexer'

describe Diffident::Lexer do

  describe "initialization" do
    it "works without any arguments" do
      Diffident::Lexer.new().class.should == Diffident::Lexer
    end

    it "requires an input that responds to .next()" do
      expect{ Diffident::Lexer.new( input: nil ) }.to raise_error ArgumentError
    end

    it "takes a string as delimiter" do
      expect{ Diffident::Lexer.new( delimiter: ' ' ) }.to_not raise_error
    end

    it "takes a regexp as delimiter" do
      expect{ Diffident::Lexer.new( delimiter: / / ) }.to_not raise_error
    end
  end

  context "basic operations" do

    context "on null object" do

      subject{ Diffident::Lexer.new() }

      it "should return empty string on .next()" do
        expect{ subject.next }.to raise_error StopIteration
      end

      it "should return false on .has_more_lexems()" do
        subject.has_more_lexems?.should == false
      end

    end

    context "with string delimiter" do
      let(:input){ ["fake file input", "simulating lines separated", "by newlines"].each }
      subject{ Diffident::Lexer.new(input: input, delimiter: ' ') }

      describe ".next() in first chunk" do
        it "should return first lexem when called once" do
          subject.next == "fake"
        end

        it "should return second lexem when called twice" do
          subject.next
          subject.next == "file"
        end

        it "should return third lexem when called thrice" do
          2.times{ subject.next }
          subject.next == "inputsimulating"
        end
      end

      describe "passing over input boundaries" do
        it "should return lexem from next chunk" do
          3.times{ subject.next }
          subject.next.should == "lines"
        end
      end

      describe "going to the end" do
        it "should return last lexem" do
          5.times{ subject.next }
          subject.next.should == "newlines"
        end
      end

      describe "going past the end" do
        it "should return raise StopIteration" do
          expect{ 7.times{ subject.next } }.to raise_error StopIteration
        end
      end
    end
  end
end