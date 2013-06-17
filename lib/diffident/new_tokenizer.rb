module Diffident
  class NewTokenizer

    require 'diffident/tokenizer/file_lexer'
    require 'diffident/tokenizer/common_sequence'
    require 'diffident/diff/new_change'

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
      add_remaining_base_lexems_as_deletions
      add_remaining_this_lexems_as_additions
      add_remaining_tail_lexems_as_same
    end

    def reduce_problem_size_by_skipping_leading_lexems_that_are_unchanged
      while @base_file.next_lexem == @this_file.next_lexem and not @base_file.current_lexem.nil?
        diff << Diffident::Diff::NewChange.new(action: :same, rows: [@base_file.row, @this_file.row], text: @base_file.current_lexem)
      end
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

    def add_remaining_this_lexems_as_additions
      last_row_of_interest = @this_file.lexems.length - @tail_length + 1
      while @this_file.row <= last_row_of_interest and @this_file.current_lexem
        diff << Diffident::Diff::NewChange.new(action: :addition, row: @this_file.row, text: @this_file.current_lexem)
        @this_file.next_lexem
      end
    end

    def add_remaining_base_lexems_as_deletions
      last_row_of_interest = @base_file.lexems.length - @tail_length + 1
      while @base_file.row <= last_row_of_interest and @base_file.current_lexem
        diff << Diffident::Diff::NewChange.new(action: :deletion, row: @base_file.row, text: @base_file.current_lexem)
        @base_file.next_lexem
      end
    end

    def add_remaining_tail_lexems_as_same
      while @base_file.current_lexem and @base_file.current_lexem
        diff << Diffident::Diff::NewChange.new(action: :same, rows: [@base_file.row, @this_file.row], text: @base_file.current_lexem)
        @base_file.next_lexem
        @this_file.next_lexem
      end
    end

    def process_complete_common_sequence( css )
      css.each_with_index do |line, row|
        unless line.nil?
          add_base_lexems_up_to_this_line_as_deletions( line )
          add_this_lexems_up_to_this_line_as_additions( line )
          diff << Diffident::Diff::NewChange.new(action: :same, rows: [@base_file.row, @this_file.row], text: line)
          @base_file.next_lexem
          @this_file.next_lexem
        end
      end
    end

    def add_base_lexems_up_to_this_line_as_deletions( line )
      while @base_file.current_lexem != line do
        diff << Diffident::Diff::NewChange.new(action: :deletion, row: @base_file.row, text: @base_file.current_lexem)
        @base_file.next_lexem
      end
    end

    def add_this_lexems_up_to_this_line_as_additions( line )
      while @this_file.current_lexem != line do
        diff << Diffident::Diff::NewChange.new(action: :addition, row: @this_file.row, text: @this_file.current_lexem)
        @this_file.next_lexem
      end
    end

    def diff
      @diff ||= []
    end
    
  end
end