require 'diffident/change'
require 'diffident/diff'
require 'diffident/tokenizer'
require 'diffident/format/ascii'
require 'diffident/format/color'
require 'diffident/format/html'

module Diffident
  class << self

    def separator=(separator)
      @@separator = separator
    end

    def separator
      @@separator
    end    

    def diff(this, base, new_sep = "\n")
      old_sep = self.separator
      self.separator = new_sep

      tokenizer = Diffident::Tokenizer.new(this, base, new_sep)
      tokenizer.run
    ensure
      self.separator = old_sep
    end

    def diff_by_char(to, from)
      diff(to, from, '')
    end

    def diff_by_word(to, from)
      diff(to, from, /\b/)
    end

    def diff_by_line(to, from)
      diff(to, from, "\n")
    end

    def format=(f)
      @format = format_for(f)
    end

    def format
      return @format || Format::Ascii
    end

    def format_for(f)
      if f.respond_to? :call
        f
      else       
        case f
        when :ascii then Format::Ascii
        when :color then Format::Color
        when :html  then Format::HTML
        when nil    then nil
        else raise "Unknown format type #{f.inspect}"
        end
      end
    end
    
  end
end