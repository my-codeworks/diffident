require 'rubygems'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'diffident'

RSpec.configure do |c|
  c.color = true
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
