class Diffident::NewDiff

  require 'diffident/diff/new_change'

  def initialize
    @lines = []
  end

  def <<( item )
    @lines << item
  end

  def add( hash )
    @lines << Diffident::Diff::NewChange.new( hash )
  end

  def add_same( hash )
    hash[:action] = :same
    add( hash )
  end

  def each( *args, &block )
    @lines.each( *args, &block )
  end

end