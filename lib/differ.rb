require 'differ/change'
require 'differ/diff'
require 'differ/format/ascii'
require 'differ/format/color'
require 'differ/format/html'

module Differ
  class << self

    def separator=(separator)
      @@separator = separator
    end

    def separator
      @@separator
    end    

    def diff(target, source, new_sep = "\n")
      old_sep = self.separator
      self.separator = new_sep

      target = target.split(new_sep)
      source = source.split(new_sep)

      self.separator = '' if new_sep.is_a? Regexp

      @diff = Diff.new
      advance(target, source) until source.empty? || target.empty?
      @diff.insert(*target) || @diff.delete(*source)
      return @diff
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

  private
    def advance(target, source)
      del, add = source.shift, target.shift

      prioritize_insert = target.length > source.length
      insert = target.index(del)
      delete = source.index(add)

      if del == add
        @diff.same(add)
      elsif insert && prioritize_insert
        change(:insert, target.unshift(add), insert)
      elsif delete
        change(:delete, source.unshift(del), delete)
      elsif insert && !prioritize_insert
        change(:insert, target.unshift(add), insert)
      else
        @diff.insert(add) && @diff.delete(del)
      end
    end

    def change(method, array, index)
      @diff.send(method, *array.slice!(0..index))
      @diff.same(array.shift)
    end
  end
end