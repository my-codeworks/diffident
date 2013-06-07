module Diffident
  class Tokenizer

    def initialize(this, base, delimiter)
      @this = this.split(delimiter)
      @base = base.split(delimiter)
      @diff = Diff.new
    end

    def run
      advance until @base.empty? || @this.empty?
      @diff.insert(*@this) unless @this.empty?
      @diff.delete(*@base) unless @base.empty?
      return @diff
    end

  private

    def advance
      del, add = @base.shift, @this.shift

      prioritize_insert = @this.length > @base.length
      insert = @this.index(del)
      delete = @base.index(add)

      if del == add
        @diff.same(add) unless add.empty?
      elsif (insert && prioritize_insert) || (insert && !delete)
        change(:insert, @this.unshift(add), insert)
      elsif delete
        change(:delete, @base.unshift(del), delete)
      else
        @diff.insert(add) unless add.empty?
        @diff.delete(del) unless del.empty?
      end
    end

    def change(method, array, index)
      sub_array = array.slice!(0..index)
      el = array.shift
      @diff.send(method, *sub_array) unless sub_array.empty?
      @diff.same(el) unless el.empty?
    end
  end
end