require 'spec_helper'
require 'diffident/string'

describe Diffident::StringDiffident do
  it 'should be automatically mixed into String' do
    String.included_modules.should include(Diffident::StringDiffident)
  end

  before(:each) do
    Diffident.separator = nil
  end

  describe '#diff' do
    it 'should call Diffident#diff' do
      Diffident.should_receive(:diff).with('TO', 'FROM', "\n").once
      'TO'.diff('FROM')
    end

    it 'should call Diffident#diff with Diffident.separator' do
      Diffident.separator = 'x'
      Diffident.should_receive(:diff).with('TO', 'FROM', Diffident.separator).once
      'TO'.diff('FROM')
    end
  end

  describe '#-' do
    it 'should call Diffident#diff' do
      Diffident.should_receive(:diff).with('TO', 'FROM', "\n").once
      'TO' - 'FROM'
    end

    it 'should call Diffident#diff with Diffident.separator' do
      Diffident.separator = 'x'
      Diffident.should_receive(:diff).with('TO', 'FROM', Diffident.separator).once
      'TO' - 'FROM'
    end
  end
end