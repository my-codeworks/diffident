require 'spec_helper'
require 'diffident/tokenizer/common_sequence'

describe Diffident::Tokenizer::CommonSequence do
  subject { Diffident::Tokenizer::CommonSequence.find( %w[a q b c d f g h j q z],  %w[a b c d e f g i j k r x y z] ) }
  it { should == ["a", nil, "b", "c", "d", "f", "g", nil, "j", nil, "z"] }
end