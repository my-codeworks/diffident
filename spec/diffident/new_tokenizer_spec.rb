require 'spec_helper'
require 'diffident/new_tokenizer'

def diff_print( diff ) 
  diff.each do |d|
    puts "%2d,%2d   %-80s %s"% [d.base_row, d.this_row, d.text, d.action]
  end
end

describe Diffident::NewTokenizer do
  it "produces output" do
    t = Diffident::NewTokenizer.new( 'spec/support/files/changed/base.css', 'spec/support/files/changed/this.css' )
    diff = t.process
  end

  context "no differances between files" do
    it "returns only :same changes" do
      t = Diffident::NewTokenizer.new( 'spec/support/files/changed/this.css', 'spec/support/files/changed/this.css' )
      diff = t.process
      # diff_print(diff)
      diff.each do |change|
        change.action.should == :same
      end
    end
  end

  context "additions to this" do
    it "are correctly detected" do
      t = Diffident::NewTokenizer.new( 'spec/support/files/changed/base.css', 'spec/support/files/changed/this.css' )
      diff = t.process
      # diff_print(diff)
      diff.each do |change|
        if (15..18).include? change.this_row
          change.action.should == :addition
        else
          change.action.should == :same
        end
      end
    end
  end

  context "deletions in this" do
    it "are correctly detected" do
      t = Diffident::NewTokenizer.new( 'spec/support/files/changed/this.css', 'spec/support/files/changed/base.css' )
      diff = t.process
      # diff_print(diff)
      diff.each do |change|
        if (15..18).include? change.base_row
          change.action.should == :deletion
        else
          change.action.should == :same
        end
      end
    end
  end

  context "complex changes between files" do
    it "are correctly marked" do
      t = Diffident::NewTokenizer.new( 'spec/support/files/changed/base.css', 'spec/support/files/changed/complex_this.css' )
      diff = t.process
      # diff_print(diff)
      diff.each do |change|
        case change.this_row
          when 9..12, 19..23
            change.action.should == :addition
          when -1
            # noop
          else
            change.action.should == :same
        end

        case change.base_row
          when 6, 7, 17, 20
            change.action.should == :deletion
          when -1
            # noop
          else
            change.action.should == :same
        end
      end
    end
  end
end