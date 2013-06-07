module Diffident
  class Format
  
    def self.call(diff_change)
      @change = diff_change
      "#{pre}#{prefix}#{diff_change.for_formatting.join( divider )}#{post}"
    end

  private

    def self.prefix
      return change if @change.change?
      return insert if @change.insert?
      return delete if @change.delete?
    end
    
    def self.pre
      "{"
    end
    
    def self.post
      "}"
    end
    
    def self.insert
      "+"
    end
    
    def self.delete
      ""
    end
    
    def self.change
      ""
    end

    def self.divider
      " >> "
    end

  end
end