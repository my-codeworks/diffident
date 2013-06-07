require 'spec_helper'

describe Diffident::Formats::Ascii do
  it 'should format inserts well' do
    @expected = '{+"SAMPLE"}'
    Diffident::Formats::Ascii.call(+'SAMPLE').should == @expected
  end

  it 'should format deletes well' do
    @expected = '{-"SAMPLE"}'
    Diffident::Formats::Ascii.call(-'SAMPLE').should == @expected
  end

  it 'should format changes well' do
    @expected = '{"THEN" >> "NOW"}'
    Diffident::Formats::Ascii.call('THEN' >> 'NOW').should == @expected
  end
end