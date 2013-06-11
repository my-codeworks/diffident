class Diffident::Tokenizer::CommonSequence

  class Book
    def initialize( base_length, this_length )
      @book = Array.new(base_length){ [0] * this_length }
      @longest_length = 0
      @longest_end_pos = 0
    end

    attr_reader :longest_length, :longest_end_pos

    def update( base_index, this_index )
      @book[base_index][this_index] = 1
      @book[base_index][this_index] += @book[base_index-1][this_index-1]
      if @book[base_index][this_index] > @longest_length
        @longest_length = @book[base_index][this_index]
        @longest_end_pos = base_index
      end
    end
  end

  def self.find( base, this )
    sequencer = self.new( base, this )
    sequencer.find
  end

  def find
    complete_subsequence( @base, @this )
  end

  def initialize( base, this )
    @base = base
    @this = this
  end

private

  def find_in_array(needle, haystack)
    pos = 0
    haystack.each_cons(needle.length) do |slice|
      break if slice == needle
      pos += 1
    end
    pos
  end

  def slice_array(array, start_pos, end_pos)
    head = start_pos > 0 ? array[0..start_pos-1] : []
    body = array[start_pos..end_pos]
    tail = end_pos+1 < array.length ? array[end_pos+1..-1] : []
    [head, body, tail]
  end

  def partition_array(array, sub_array)
    start_pos = find_in_array(sub_array, array)
    end_pos = start_pos+sub_array.length-1
    slice_array(array, start_pos, end_pos)
  end

  def complete_subsequence( base_array, this_array )
    subssequence, base_ss_start, base_ss_end = longest_common_subsequence( base_array, this_array )
    
    if subssequence.compact.any?
    
      base_head, _, base_tail = slice_array(base_array, base_ss_start, base_ss_end)
      this_head, _, this_tail = partition_array(this_array, subssequence.compact)

      if base_head.any? and this_head.any?
        ss = complete_subsequence( base_head, this_head )
        subssequence[0..ss.length-1] = *ss if ss.compact.any?
      end

      if base_tail.any? and this_tail.any?
        ss = complete_subsequence( base_tail, this_tail )
        subssequence[subssequence.length-ss.length..-1] = *ss if ss.compact.any?
      end

    end

    subssequence
  end

  def longest_common_subsequence( base, this )

    book = Book.new( base.length, this.length )

    base.each_with_index do |base_element, base_index|
      this.each_with_index do |this_element, this_index|
        book.update( base_index, this_index ) if base_element == this_element
      end
    end

    longest_start_pos = book.longest_end_pos - book.longest_length + 1

    ss = Array.new( base.length )
    ss[longest_start_pos..book.longest_end_pos] = *base[longest_start_pos .. book.longest_end_pos]
    return ss, longest_start_pos, book.longest_end_pos
  end

end