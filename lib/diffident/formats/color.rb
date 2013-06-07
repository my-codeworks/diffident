module Diffident
  module Formats
    class Color < Format
    private
      
      def self.pre
        "\033"
      end
      
      def self.post
        "\033[0m"
      end
      
      def self.insert
        "[32m"
      end
      
      def self.delete
        "[31m"
      end
      
      def self.change
        "[31m"
      end

      def self.divider
        "\e[0m\e[32m"
      end
      
    end
  end
end