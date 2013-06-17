class Diffident::Tokenizer::FileLexer

  require 'diffident/lexer'

  def initialize( file_name )
    @lexems = []
    @row = 0
    @file = File.open( file_name )
  end

  def next_lexem  
    @row += 1
    @lexems[@row] = lexer.next if lexer.has_more_lexems?
    current_lexem
  end

  def row
    @row
  end

  def []( index )
    lexems[index]
  end

  def current_lexem
    @lexems[@row]
  end

  def lexems
    load_lexems if lexer.has_more_lexems?
    @lexems[1..-1]
  end

  def has_more_lexems?
    lexer.has_more_lexems?
  end

  def finish
    @file.close
  end

private

  def lexer
    @lexer ||= Diffident::Lexer.new( input: @file.each )
  end

  def load_lexems
    row = @row
    @lexems[row += 1] = lexer.next while lexer.has_more_lexems?
  end

end
