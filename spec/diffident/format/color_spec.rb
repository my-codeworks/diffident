require 'spec_helper'

describe Diffident::Format::Color do
  it 'should format inserts well' do
    @expected = "\033[32mSAMPLE\033[0m"
    Diffident::Format::Color.call(+'SAMPLE').should == @expected
  end

  it 'should format deletes well' do
    @expected = "\033[31mSAMPLE\033[0m"
    Diffident::Format::Color.call(-'SAMPLE').should == @expected
  end

  it 'should format changes well' do
    @expected = "\033[31mTHEN\033[0m\033[32mNOW\033[0m"
    Diffident::Format::Color.call('THEN' >> 'NOW').should == @expected
  end
end