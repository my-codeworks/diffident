require 'spec_helper'

describe Diffident::Format::Ascii do
  it 'should format inserts well' do
    @expected = '{+"SAMPLE"}'
    Diffident::Format::Ascii.call(+'SAMPLE').should == @expected
  end

  it 'should format deletes well' do
    @expected = '{-"SAMPLE"}'
    Diffident::Format::Ascii.call(-'SAMPLE').should == @expected
  end

  it 'should format changes well' do
    @expected = '{"THEN" >> "NOW"}'
    Diffident::Format::Ascii.call('THEN' >> 'NOW').should == @expected
  end
end