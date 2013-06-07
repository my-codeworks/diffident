module Diffident
  class NewTokenizer

    require 'diffident/lexer'

    def process( base_file_name, this_file_name )
      base_file = File.open( base_file_name )
      this_file = File.open( this_file_name )

      base_lexer = Lexer.new( input: base_file.each )
      this_lexer = Lexer.new( input: this_file.each )

      last_action = :same

      begin
        
        base_lexem = base_lexer.next if last_action == :same or last_action == :deletion
        this_lexem = this_lexer.next if last_action == :same or last_action == :addition

        css = complete_substring( base_lexem, this_lexem )

        puts("#{base_lexem} <> #{this_lexem} => #{css}")
        
      end while base_lexer.has_more_lexems? or this_lexer.has_more_lexems?

      base_lexer = nil
      this_lexer = nil

      base_file.close
      this_file.close
    end

  private

    def change_set( base_text, this_text )
      css = complete_substring( base_lexem, this_lexem )
    end

    def complete_substring( base_text, this_text )
      substring, start_pos, end_pos = longest_common_substring( base_text, this_text )

      pre_ss = ''
      post_ss = ''

      if substring != ''
        base_head, base_sep, base_tail = base_text.partition( substring )
        this_head, this_sep, this_tail = this_text.partition( substring )

        unless base_head == '' or this_head == ''
          pre_ss, _, _  = complete_substring( base_head, this_head )
        end

        unless base_tail == '' or this_tail == ''
          post_ss, _, _ = complete_substring( base_tail, this_tail )
        end
      end

      "#{pre_ss}#{substring}#{post_ss}"
    end

    def longest_common_substring(s1, s2)
      if (s1 == "" || s2 == "")
        return ""
      end
      m = Array.new(s1.length){ [0] * s2.length }
      longest_length, longest_end_pos = 0,0
      (0 .. s1.length - 1).each do |x|
        (0 .. s2.length - 1).each do |y|
          if s1[x] == s2[y]
            m[x][y] = 1
            if (x > 0 && y > 0)
              m[x][y] += m[x-1][y-1]
            end
            if m[x][y] > longest_length
              longest_length = m[x][y]
              longest_end_pos = x
            end
          end
        end
      end
      longest_start_pos = longest_end_pos - longest_length + 1
      return s1[longest_start_pos .. longest_end_pos], longest_start_pos, longest_end_pos
    end

  end
end