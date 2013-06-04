require 'rubygems'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'diffident'

RSpec.configure do |c|
  c.color = true
end

def diff(*parts)
  x = Diffident::Diff.new
  x.instance_variable_set(:@raw, parts)
  return x
end

class String
  def +@
    Diffident::Change.new(:insert => self)
  end

  def -@
    Diffident::Change.new(:delete => self)
  end

  def >>(to)
    Diffident::Change.new(:delete => self, :insert => to)
  end
end
