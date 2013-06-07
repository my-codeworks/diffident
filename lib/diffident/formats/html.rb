module Diffident
  module Formats
    class HTML < Format
    private

      def self.pre
        "<p><span "
      end
      
      def self.post
        "</span></p>"
      end
      
      def self.insert
        "class=\"diffident-insert\">"
      end
      
      def self.delete
        "class=\"diffident-delete\">"
      end
      
      def self.change
        "class=\"diffident-change-from\">"
      end

      def self.divider
        "</span><span class=\"diffident-change-to\">"
      end
      
    end
  end
end