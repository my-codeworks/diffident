module Diffident
  module Formats
    class Ascii < Format
    private

      def self.pre
        "{"
      end
      
      def self.post
        "\"}"
      end
      
      def self.insert
        "+\""
      end
      
      def self.delete
        "-\""
      end
      
      def self.change
        "\""
      end

      def self.divider
        "\" >> \""
      end
      
    end
  end
end