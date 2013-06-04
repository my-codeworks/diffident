require 'spec_helper'

describe Diffident::Change do
  before(:each) do
    @format = Module.new { def self.call(c); end }
    Diffident.format = @format
  end

  describe '(empty)' do
    before(:each) do
      @change = Diffident::Change.new()
    end

    it 'should have a default insert' do
      @change.insert.should == ''
    end

    it 'should have a default delete' do
      @change.delete.should == ''
    end

    it 'should stringify to ""' do
      @format.should_receive(:call).once.and_return('')
      @change.to_s.should == ''
    end
  end

  describe '(insert only)' do
    before(:each) do
      @change = Diffident::Change.new(:insert => 'foo')
    end

    it 'should populate the :insert parameter' do
      @change.insert.should == 'foo'
    end

    it 'should have a default delete' do
      @change.delete.should == ''
    end

    it { (@change).should be_an_insert }
  end

  describe '(delete only)' do
    before(:each) do
      @change = Diffident::Change.new(:delete => 'bar')
    end

    it 'should have a default :insert' do
      @change.insert.should == ''
    end

    it 'should populate the :delete parameter' do
      @change.delete.should == 'bar'
    end

    it { (@change).should be_a_delete }
  end

  describe '(both insert and delete)' do
    before(:each) do
      @change = Diffident::Change.new(:insert => 'foo', :delete => 'bar')
    end

    it 'should populate the :insert parameter' do
      @change.insert.should == 'foo'
    end

    it 'should populate the :delete parameter' do
      @change.delete.should == 'bar'
    end

    it { (@change).should be_an_insert }
    it { (@change).should be_a_delete }
    it { (@change).should be_a_change }
  end

  it "should stringify via the current format's #format method" do
    @format.should_receive(:call).once
    Diffident::Change.new.to_s
  end
end