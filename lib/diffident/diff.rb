module Diffident
  class Diff

    def initialize
      @changes = []
    end

    def same( *lexems )
      if last_change.is_a? String
        last_change << change_text_from( '', *lexems )
      elsif last_change.is_a? Change
        if last_change.change?
          lexems.unshift('')
        else
          update_insert
          update_delete
        end
        changes << change_text_from( lexems )
      else
        changes << change_text_from( lexems )
      end
    end

    def delete(*lexems)
      if last_change.is_a? Change
        update_delete
      else
        add_new_change( delete: last_change.nil? ? '' : delim )
      end
      last_change.delete << change_text_from( lexems )
    end

    def insert(*lexems)
      if last_change.is_a? Change
        update_insert
      else
        add_new_change( insert: last_change.nil? ? '' : delim )
      end
      last_change.insert << change_text_from( lexems )
    end

    def ==(other)
      @changes == other.changes
    end

    def to_s
      @changes.join()
    end

    def format_as(f)
      f = Diffident.format_for(f)
      @changes.inject('') do |sum, part|
        part = case part
        when String then part
        when Change then f.call(part)
        end
        sum << part
      end
    end

  protected

    def changes
      @changes
    end

  private

    def last_change
      changes[-1]
    end

    def second_to_last_change
      changes[-2]
    end

    def update_delete
      append_delimiter_to_second_to_last_change if second_to_last_change and delimiter_removed_from_start_of_last_changes?( :insert )
      append_delimiter_to_last_changes( :delete ) if last_change.delete?
    end

    def update_insert
      append_delimiter_to_second_to_last_change if second_to_last_change and delimiter_removed_from_start_of_last_changes?( :delete )
      append_delimiter_to_last_changes( :insert ) if last_change.insert?
    end

    def append_delimiter_to_second_to_last_change
      second_to_last_change << delim
    end

    def removed_delimiter_from_start_of?( what )
      not what.sub!(/^#{Regexp.quote(delim)}/, '').to_s.empty?
    end

    def delimiter_removed_from_start_of_last_changes?( part )
      removed_delimiter_from_start_of?( last_change.send( part ) )
    end

    def append_delimiter_to_last_changes( part )
      last_change.send( part ) << delim
    end

    def add_new_change( args = {} )
      changes << Diffident::Change.new( args )
    end

    def change_text_from( *lexems )
      lexems.join(delim)
    end

    def delim
      Diffident.delimiter.is_a?(Regexp) ? '' : "#{Diffident.delimiter}"
    end

  end
end
