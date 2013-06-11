class Diffident::Tokenizer::CommonSequence

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
    head = start_pos-1 > 0 ? array[0..start_pos-1] : []
    body = array[start_pos..end_pos]
    tail = end_pos+1 < array.length ? array[end_pos+1..-1] : []
    [head, body, tail]
  end

  def partition_array(array, sub_array)
    start_pos = find_in_array(sub_array, array)
    end_pos = start_pos+sub_array.length-1
    slice_array(array, start_pos, end_pos)
  end

  def complete_subsequence( base_array, this_array, indent = 0 )
    subssequence, base_ss_start, base_ss_end = longest_common_subsequence( base_array, this_array )
    
    if subssequence.compact.any?
    
      base_head, _, base_tail = slice_array(base_array, base_ss_start, base_ss_end)
      this_head, _, this_tail = partition_array(this_array, subssequence.compact)

      if base_head.any? and this_head.any?
        ss = complete_subsequence( base_head, this_head, indent+1 )
        subssequence.insert(0, *ss.compact) if ss.compact.any?
      end

      if base_tail.any? and this_tail.any?
        ss = complete_subsequence( base_tail, this_tail, indent+1 )
        subssequence.insert(subssequence.length-1-ss.length-1, *ss.compact) if ss.compact.any?
      end

    end

    subssequence
  end

  def longest_common_subsequence(s1, s2)
    return [], 0, 0 if s1.empty? or s2.empty?
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
    ss = Array.new( s1.length )
    ss.insert(longest_start_pos, *s1[longest_start_pos .. longest_end_pos])
    return ss, longest_start_pos, longest_end_pos
  end

end