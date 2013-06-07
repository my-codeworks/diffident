require 'spec_helper'
require 'diffident/new_tokenizer'

describe Diffident::NewTokenizer do
  it "produces output" do
    t = Diffident::NewTokenizer.new
    t.process( 'spec/support/test1', 'spec/support/test2' )
  end
end