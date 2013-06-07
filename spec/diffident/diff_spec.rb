require 'spec_helper'

def diff(*parts)
  x = Diffident::Diff.new
  x.instance_variable_set(:@changes, parts)
  return x
end

describe Diffident::Diff do
  before(:each) do
    Diffident.delimiter = nil
    @diff = Diffident::Diff.new
  end

  describe '#to_s' do
    before(:each) do
      @format = Diffident.format
    end

    it 'should concatenate the result list' do
      diff('a', 'b', 'c').to_s.should == 'abc'
    end

    it 'should concatenate without regard for the Diffident.delimiter' do
      Diffident.delimiter = '*'
      diff('a', 'b', 'c').to_s.should == 'abc'
    end

    it 'should delegate insertion changes to Diffident#format' do
      i = +'b'
      @format.should_receive(:call).once.with(i).and_return('!')
      diff('a', i, 'c').to_s.should == 'a!c'
    end
  end

  describe '#format_as' do
    before(:each) do
      @change = +'b'
      Diffident.format = Module.new { def self.call(c); raise :error; end }
      @format = Module.new { def self.call(c); end }
    end

    it 'should delegate change formatting to the given format' do
      @format.should_receive(:call).once.with(@change).and_return('!')
      diff('a', @change, 'c').format_as(@format).should == 'a!c'
    end

    it 'should use Diffident#format_for to grab the correct format' do
      Diffident.should_receive(:format_for).once.with(@format)
      diff().format_as(@format)
    end
  end

  describe '#same' do
    it 'should append to the result list' do
      @diff.same('c')
      @diff.should == diff('c')
    end

    it 'should concatenate its arguments' do
      @diff.same('a', 'b', 'c', 'd')
      @diff.should == diff('abcd')
    end

    it 'should join its arguments with Diffident.delimiter' do
      Diffident.delimiter = '*'
      @diff.same(*'a*b*c*d'.split)
      @diff.should == diff('a*b*c*d')
    end

    describe 'when the last result was a String' do
      before(:each) do
        @diff = diff('a')
      end

      it 'should append to the last result' do
        @diff.same('b')
        @diff.should == diff('ab')
      end

      it 'should join to the last result with Diffident.delimiter' do
        Diffident.delimiter = '*'
        @diff.same('b')
        @diff.should == diff('a*b')
      end
    end

    describe 'when the last result was a change' do
      before(:each) do
        @diff = diff('z' >> 'd')
      end

      it 'should append to the result list' do
        @diff.same('a')
        @diff.should == diff(('z' >> 'd'), 'a')
      end

      it 'should prepend Diffident.delimiter to the result' do
        Diffident.delimiter = '*'
        @diff.same('a')
        @diff.should == diff(('z' >> 'd'), '*a')
      end

      it "should do nothing to a leading Diffident.delimiter on the insert" do
        @diff = diff('a', ('*-' >> '*+'))
        Diffident.delimiter = '*'
        @diff.same('c')
        @diff.should == diff('a', ('*-' >> '*+'), '*c')
      end
    end

    describe 'when the last result was just a delete' do
      before(:each) do
        @diff = diff(-'z')
      end

      it 'should append to the result list' do
        @diff.same('a')
        @diff.should == diff(-'z', 'a')
      end

      it 'should append Diffident.delimiter to the previous result' do
        Diffident.delimiter = '*'
        @diff.same('a')
        @diff.should == diff(-'z*', 'a')
      end

      it "should relocate a leading Diffident.delimiter on the delete to the previous item" do
        @diff = diff('a', -'*b')
        Diffident.delimiter = '*'
        @diff.same('c')
        @diff.should == diff('a*', -'b*', 'c')
      end
    end

    describe 'when the last result was just an insert' do
      before(:each) do
        @diff = diff(+'z')
      end

      it 'should append to the result list' do
        @diff.same('a')
        @diff.should == diff(+'z', 'a')
      end

      it 'should append Diffident.delimiter to the previous result' do
        Diffident.delimiter = '*'
        @diff.same('a')
        @diff.should == diff(+'z*', 'a')
      end

      it "should relocate a leading Diffident.delimiter on the insert to the previous item" do
        @diff = diff('a', +'*b')
        Diffident.delimiter = '*'
        @diff.same('c')
        @diff.should == diff('a*', +'b*', 'c')
      end
    end
  end

  describe '#delete' do
    it 'should append to the result list' do
      @diff.delete('c')
      @diff.should == diff(-'c')
    end

    it 'should concatenate its arguments' do
      @diff.delete('a', 'b', 'c', 'd')
      @diff.should == diff(-'abcd')
    end

    it 'should join its arguments with Diffident.delimiter' do
      Diffident.delimiter = '*'
      @diff.delete(*'a*b*c*d'.split)
      @diff.should == diff(-'a*b*c*d')
    end

    describe 'when the last result was a Change' do
      describe '(delete)' do
        before(:each) do
          @diff = diff(-'a')
        end

        it 'should append to the last result' do
          @diff.delete('b')
          @diff.should == diff(-'ab')
        end

        it 'should join to the last result with Diffident.delimiter' do
          Diffident.delimiter = '*'
          @diff.delete('b')
          @diff.should == diff(-'a*b')
        end
      end

      describe '(insert)' do
        before(:each) do
          @diff = diff(+'a')
        end

        it "should turn the insert into a change" do
          @diff.delete('b')
          @diff.should == diff('b' >> 'a')
        end

        it "should relocate a leading Diffident.delimiter on the insert to the previous item" do
          @diff = diff('a', +'*b')
          Diffident.delimiter = '*'
          @diff.delete('z')
          @diff.should == diff('a*', ('z' >> 'b'))
        end
      end
    end

    describe 'when the last result was not a Change' do
      before(:each) do
        @diff = diff('a')
      end

      it 'should append a Change to the result list' do
        @diff.delete('b')
        @diff.should == diff('a', -'b')
      end

      it 'should prepend Diffident.delimiter to the result' do
        Diffident.delimiter = '*'
        @diff.delete('b')
        @diff.should == diff('a', -'*b')
      end
    end
  end

  describe '#insert' do
    it 'should append to the result list' do
      @diff.insert('c')
      @diff.should == diff(+'c')
    end

    it 'should concatenate its arguments' do
      @diff.insert('a', 'b', 'c', 'd')
      @diff.should == diff(+'abcd')
    end

    it 'should join its arguments with Diffident.delimiter' do
      Diffident.delimiter = '*'
      @diff.insert(*'a*b*c*d'.split)
      @diff.should == diff(+'a*b*c*d')
    end

    describe 'when the last result was a Change' do
      describe '(delete)' do
        before(:each) do
          @diff = diff(-'b')
        end

        it "should not change the 'insert' portion of the last result" do
          @diff.insert('a')
          @diff.should == diff('b' >> 'a')
        end

        it "should relocate a leading Diffident.delimiter on the delete to the previous item" do
          @diff = diff('a', -'*b')
          Diffident.delimiter = '*'
          @diff.insert('z')
          @diff.should == diff('a*', ('b' >> 'z'))
        end
      end

      describe '(insert)' do
        before(:each) do
          @diff = diff(+'a')
        end

        it 'should append to the last result' do
          @diff.insert('b')
          @diff.should == diff(+'ab')
        end

        it 'should join to the last result with Diffident.delimiter' do
          Diffident.delimiter = '*'
          @diff.insert('b')
          @diff.should == diff(+'a*b')
        end
      end
    end

    describe 'when the last result was not a Change' do
      before(:each) do
        @diff = diff('a')
      end

      it 'should append a Change to the result list' do
        @diff.insert('b')
        @diff.should == diff('a', +'b')
      end

      it 'should prepend Diffident.delimiter to the result' do
        Diffident.delimiter = '*'
        @diff.insert('b')
        @diff.should == diff('a', +'*b')
      end
    end
  end
end