module Diffident
  class NewTokenizer

    require 'diffident/lexer'
    require 'diffident/tokenizer/common_sequence'

    Change = Struct.new :action, :base_row, :this_row, :text

    def initialize( base_file_name, this_file_name )
      @base_file_name = base_file_name
      @this_file_name = this_file_name
      @tail_lexems = []
      @base_row = 0
      @this_row = 0
    end

    def process

      @base_file = File.open( @base_file_name )
      @this_file = File.open( @this_file_name )

      reduce_problem_size_by_skipping_leading_lexems_that_are_unchanged

      load_remaining_lexems_into_memory

      reduce_problem_size_by_skipping_trailing_lexems_that_are_unchanged

      base_lexems.compact!
      this_lexems.compact!

      if this_lexems.compact.any? and base_lexems.compact.any?

        css = Diffident::Tokenizer::CommonSequence.find( base_lexems.compact, this_lexems.compact )

        add_base_lexems_not_in_complete_common_subsequence_as_deletions(css)
      end

      add_remaining_base_lexems_as_deletions
      add_remaining_this_lexems_as_additions
      add_remaining_tail_lexems_as_same

      @base_file.close
      @this_file.close

      return diff
    end

  private

    def reduce_problem_size_by_skipping_leading_lexems_that_are_unchanged
      begin
        base_lexem = base_lexer.next
        this_lexem = this_lexer.next

        diff << Change.new(:same, @base_row += 1, @this_row += 1, base_lexem) if base_lexem == this_lexem
        
      end while base_lexem == this_lexem and base_lexer.has_more_lexems? and this_lexer.has_more_lexems?
    end

    def load_remaining_lexems_into_memory
      if base_lexer.has_more_lexems?
        base_lexems[@base_row += 1] = base_lexer.latest
        base_lexems[@base_row += 1] = base_lexer.next while base_lexer.has_more_lexems?
      end
      if this_lexer.has_more_lexems?
        this_lexems[@this_row += 1] = this_lexer.latest
        this_lexems[@this_row += 1] = this_lexer.next while this_lexer.has_more_lexems?
      end
      @base_row -= base_lexems.compact.length
      @this_row -= this_lexems.compact.length
    end

    def reduce_problem_size_by_skipping_trailing_lexems_that_are_unchanged
      if base_lexems.any? and this_lexems.any?
        tail_length = 0
        tail_length += 1 while base_lexems[-(tail_length+1)] == this_lexems[-(tail_length+1)]
        
        @tail_lexems = base_lexems.pop(tail_length)
        this_lexems.pop(tail_length)
      end
    end

    def add_remaining_this_lexems_as_additions
      this_lexems.each do |lexem|
        diff << Change.new(:addition, -1, @this_row += 1, lexem) unless lexem.nil?
      end
    end

    def add_remaining_base_lexems_as_deletions
      base_lexems.each do |lexem|
        diff << Change.new(:deletion, @base_row += 1, -1, lexem) unless lexem.nil?
      end
    end

    def add_remaining_tail_lexems_as_same
      @tail_lexems.each do |d|
        @base_row += 1
        @this_row += 1
        diff << Change.new(:same, @base_row, @this_row, d)
      end
    end

    def add_base_lexems_not_in_complete_common_subsequence_as_deletions( css )
      css.each_with_index do |line, row|
        unless line.nil?
          add_base_lexems_up_to_this_line_as_deletions(line)
          add_this_lexems_up_to_this_line_as_additions(line)
          base_lexems.shift
          this_lexems.shift
          diff << Change.new(:same, @base_row += 1, @this_row += 1, line)
        end
      end
    end

    def add_base_lexems_up_to_this_line_as_deletions( line )
      while base_lexems.compact.first != line do
        diff << Change.new(:deletion, @base_row += 1, -1, base_lexems.shift)
      end
    end

    def add_this_lexems_up_to_this_line_as_additions( line )
      while this_lexems.compact.first != line do
        diff << Change.new(:addition, -1, @this_row += 1, this_lexems.shift)
      end
    end

    def base_lexems
      @base_lexems ||= []
    end

     def this_lexems
      @this_lexems ||= []
    end

    def diff
      @diff ||= []
    end

    def base_lexer
      @base_lexer ||= Lexer.new( input: @base_file.each )
    end

    def this_lexer
      @this_lexer ||= Lexer.new( input: @this_file.each )
    end
    
  end
end