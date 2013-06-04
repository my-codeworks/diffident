require 'spec_helper'

describe Diffident::Format::HTML do
  it 'should format inserts well' do
    @expected = '<ins class="Diffident">SAMPLE</ins>'
    Diffident::Format::HTML.call(+'SAMPLE').should == @expected
  end

  it 'should format deletes well' do
    @expected = '<del class="Diffident">SAMPLE</del>'
    Diffident::Format::HTML.call(-'SAMPLE').should == @expected
  end

  it 'should format changes well' do
    @expected = '<del class="Diffident">THEN</del><ins class="Diffident">NOW</ins>'
    Diffident::Format::HTML.call('THEN' >> 'NOW').should == @expected
  end
end