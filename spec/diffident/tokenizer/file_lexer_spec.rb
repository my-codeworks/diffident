require 'spec_helper'
require 'diffident/tokenizer/file_lexer'

describe Diffident::Tokenizer::FileLexer do

  subject { Diffident::Tokenizer::FileLexer.new( 'spec/support/files/changed/base.css' ) }

  context "getting tokens one by one" do

    it "should yield lexems one by one" do
      subject.next_lexem.should == "@import url(http://fonts.googleapis.com/css?family=Cinzel:400,700);"
      subject.next_lexem.should == ""
      subject.next_lexem.should == "#login_box {"
    end

    it "should track what row it's on" do
      3.times{ subject.next_lexem }
      subject.row.should == 3
    end

    describe ".current_lexem()" do

      before(:each){ 3.times{ subject.next_lexem } }

      it "should be same as last next_lexem when called right after" do
        subject.next_lexem.should == subject.current_lexem
      end

      it "should not affect the row pointer" do
        subject.row.should == 3
        3.times{ subject.current_lexem }
        subject.row.should == 3
      end

    end

  end

  context ".lexems()" do

    it "should yield all lexems" do
      subject.lexems.length.should == 25
    end

    it "should yield ordered rows" do
      subject.lexems[00].should == "@import url(http://fonts.googleapis.com/css?family=Cinzel:400,700);"
      subject.lexems[15].should == "  border-bottom: 2px solid;"
      subject.lexems[22].should == "article[role=main] {"
    end

    it "should contain lexems read with .next_lexem()" do
      subject.next_lexem
      subject.lexems[00].should == "@import url(http://fonts.googleapis.com/css?family=Cinzel:400,700);"
    end

    it "should not change the row pointer" do
      3.times{ subject.next_lexem }
      subject.row.should == 3
      subject.lexems
      subject.row.should == 3
    end

    it "should contain lexems not yet read with .next_lexem()" do
      subject.next_lexem
      subject.lexems[10].should == "nav .row {"
    end

    it "should not contain duplicates" do
      3.times{ subject.next_lexem }
      subject.lexems.each_cons(2) do |(a, b)|
        a.should_not == b
      end
    end

  end

end