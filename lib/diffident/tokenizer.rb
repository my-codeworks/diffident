module Diffident
  class Tokenizer

    def initialize(this, base, separator)
      @this = this.split(separator)
      @base = base.split(separator)
      @diff = Diff.new
    end

    def run
      advance until @base.empty? || @this.empty?
      @diff.insert(*@this) || @diff.delete(*@base)
      return @diff
    end

  private

    def advance
      del, add = @base.shift, @this.shift

      prioritize_insert = @this.length > @base.length
      insert = @this.index(del)
      delete = @base.index(add)

      if del == add
        @diff.same(add)
      elsif insert && prioritize_insert
        change(:insert, @this.unshift(add), insert)
      elsif delete
        change(:delete, @base.unshift(del), delete)
      elsif insert
        change(:insert, @this.unshift(add), insert)
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