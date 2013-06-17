module Diffident
  class NewTokenizer

    attr_accessor :this_row

    require 'diffident/tokenizer/file_lexer'
    require 'diffident/tokenizer/common_sequence'

    Change = Struct.new :action, :base_row, :this_row, :text

    def initialize( base_file_name, this_file_name )
      @base_file_name = base_file_name
      @this_file_name = this_file_name
      @tail_length = 0
    end

    def process
      @base_file = Diffident::Tokenizer::FileLexer.new( @base_file_name )
      @this_file = Diffident::Tokenizer::FileLexer.new( @this_file_name )

      reduce_problem_size_by_skipping_leading_lexems_that_are_unchanged
      reduce_problem_size_by_skipping_trailing_lexems_that_are_unchanged

      if ( base_lexems = [ @base_file.lexems[@base_file.row() -1 .. -@tail_length] ].flatten ).any? and
         ( this_lexems = [ @this_file.lexems[@this_file.row() -1 .. -@tail_length] ].flatten ).any?
        complete_common_sequence = Diffident::Tokenizer::CommonSequence.find( base_lexems, this_lexems )
        process_complete_common_sequence( complete_common_sequence )
      end

      add_remaining_base_lexems_as_deletions
      add_remaining_this_lexems_as_additions
      add_remaining_tail_lexems_as_same

      @base_file.finish
      @this_file.finish

      return diff
    end

  private

    def reduce_problem_size_by_skipping_leading_lexems_that_are_unchanged
      while @base_file.next_lexem == @this_file.next_lexem and not @base_file.current_lexem.nil?
        diff << Change.new(:same, @base_file.row, @this_file.row, @base_file.current_lexem)
      end
    end

    def reduce_problem_size_by_skipping_trailing_lexems_that_are_unchanged
      max_tail_length = [
                          @base_file.lexems.length - @base_file.row,
                          @this_file.lexems.length - @this_file.row
                        ].min

      @tail_length += 1 while @base_file.lexems[-@tail_length] and
                              @base_file.lexems[-@tail_length] == @this_file.lexems[-@tail_length] and
                              @tail_length <= max_tail_length
    end

    def add_remaining_this_lexems_as_additions
      last_row_of_interest = @this_file.lexems.length - @tail_length + 1
      while @this_file.row <= last_row_of_interest and @this_file.current_lexem
        diff << Change.new(:addition, -1, @this_file.row, @this_file.current_lexem)
        @this_file.next_lexem
      end
    end

    def add_remaining_base_lexems_as_deletions
      last_row_of_interest = @base_file.lexems.length - @tail_length + 1
      while @base_file.row <= last_row_of_interest and @base_file.current_lexem
        diff << Change.new(:deletion, @base_file.row, -1, @base_file.current_lexem)
        @base_file.next_lexem
      end
    end

    def add_remaining_tail_lexems_as_same
      while @base_file.current_lexem and @base_file.current_lexem
        diff << Change.new(:same, @base_file.row, @this_file.row, @base_file.current_lexem)
        @base_file.next_lexem
        @this_file.next_lexem
      end
    end

    def process_complete_common_sequence( css )
      css.each_with_index do |line, row|
        unless line.nil?
          add_base_lexems_up_to_this_line_as_deletions( line )
          add_this_lexems_up_to_this_line_as_additions( line )
          diff << Change.new(:same, @base_file.row, @this_file.row, line)
          @base_file.next_lexem
          @this_file.next_lexem
        end
      end
    end

    def add_base_lexems_up_to_this_line_as_deletions( line )
      while @base_file.current_lexem != line do
        diff << Change.new(:deletion, @base_file.row, -1, @base_file.current_lexem)
        @base_file.next_lexem
      end
    end

    def add_this_lexems_up_to_this_line_as_additions( line )
      while @this_file.current_lexem != line do
        diff << Change.new(:addition, -1, @this_file.row, @this_file.current_lexem)
        @this_file.next_lexem
      end
    end

    def diff
      @diff ||= []
    end
    
  end
end