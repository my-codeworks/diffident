module Diffident
  class NewTokenizer

    require 'diffident/tokenizer/file_lexer'
    require 'diffident/tokenizer/common_sequence'
    require 'diffident/diff/new_change'
    require 'diffident/new_diff'

    def initialize( base_file_name, this_file_name )
      @base_file_name = base_file_name
      @this_file_name = this_file_name
      @tail_length = 0
    end

    def process
      @base_file = Diffident::Tokenizer::FileLexer.new( @base_file_name )
      @this_file = Diffident::Tokenizer::FileLexer.new( @this_file_name )

      problem_size_reduction
      detect_interleaved_changes
      process_remaining_changes

      @base_file.finish
      @this_file.finish

      return diff
    end

  private

    def problem_size_reduction
      reduce_problem_size_by_skipping_leading_lexems_that_are_unchanged
      reduce_problem_size_by_skipping_trailing_lexems_that_are_unchanged
    end

    def detect_interleaved_changes
      base_lexems = lexems_without_head_and_tail( @base_file )
      this_lexems = lexems_without_head_and_tail( @this_file )

      if base_lexems.any? and this_lexems.any?
        complete_common_sequence = Diffident::Tokenizer::CommonSequence.find( base_lexems, this_lexems )
        process_complete_common_sequence( complete_common_sequence )
      end
    end

    def process_remaining_changes
      add_remaining_lexems_as( :deletion, @base_file )
      add_remaining_lexems_as( :addition, @this_file )
      add_remaining_tail_lexems_as_same
    end

    def leading_lexems_are_the_same?
      lexems_equal = @base_file.next_lexem == @this_file.next_lexem
      lexems_not_nil = (not @base_file.current_lexem.nil?)
      lexems_equal and lexems_not_nil
    end

    def reduce_problem_size_by_skipping_leading_lexems_that_are_unchanged
      add_same_line_to_diff while leading_lexems_are_the_same?
    end

    def max_tail_length 
      [
        @base_file.lexems.length - @base_file.row,
        @this_file.lexems.length - @this_file.row
      ].min
    end

    def trailing_lexems_are_the_same?
      @base_file.lexems[-@tail_length] and
      @base_file.lexems[-@tail_length] == @this_file.lexems[-@tail_length] and
      @tail_length <= max_tail_length
    end

    def reduce_problem_size_by_skipping_trailing_lexems_that_are_unchanged
      @tail_length += 1 while trailing_lexems_are_the_same?
    end

    def lexems_without_head_and_tail( file_lexer )
      from = file_lexer.row() -1
      to = -@tail_length
      file_lexer.lexems[from .. to]
    end

    def add_remaining_lexems_as( action, file_lexer )
      last_row_of_interest = file_lexer.lexems.length - @tail_length + 1
      while file_lexer.row <= last_row_of_interest and file_lexer.current_lexem
        add_line_to_diff_and_advance_file_lexer( action, file_lexer )
      end
    end

    def add_remaining_tail_lexems_as_same
      while @base_file.current_lexem and @base_file.current_lexem
        add_same_line_to_diff
        @base_file.next_lexem
        @this_file.next_lexem
      end
    end

    def process_complete_common_sequence( css )
      css.each_with_index do |line, row|
        unless line.nil?
          add_lexems_up_to_this_line_as( :deletion, @base_file, line )
          add_lexems_up_to_this_line_as( :addition, @this_file, line )
          add_same_line_to_diff
          @base_file.next_lexem
          @this_file.next_lexem
        end
      end
    end

    def add_lexems_up_to_this_line_as( action, file_lexer, line )
      while file_lexer.current_lexem != line do
        add_line_to_diff_and_advance_file_lexer( action, file_lexer )
        
      end
    end

    def add_line_to_diff_and_advance_file_lexer( action, file_lexer )
      diff.add(action: action, row: file_lexer.row, text: file_lexer.current_lexem)
      file_lexer.next_lexem
    end

    def add_same_line_to_diff
      diff.add_same(rows: [@base_file.row, @this_file.row], text: @base_file.current_lexem)
    end

    def diff
      @diff ||= NewDiff.new
    end
    
  end
end