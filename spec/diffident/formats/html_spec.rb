require 'spec_helper'

describe Diffident::Formats::HTML do
  it 'should format inserts well' do
    @expected = "<p><span class=\"diffident-insert\">SAMPLE</span></p>"
    Diffident::Formats::HTML.call(+'SAMPLE').should == @expected
  end

  it 'should format deletes well' do
    @expected = "<p><span class=\"diffident-delete\">SAMPLE</span></p>"
    Diffident::Formats::HTML.call(-'SAMPLE').should == @expected
  end

  it 'should format changes well' do
    @expected = "<p><span class=\"diffident-change-from\">THEN</span><span class=\"diffident-change-to\">NOW</span></p>"
    Diffident::Formats::HTML.call('THEN' >> 'NOW').should == @expected
  end
end