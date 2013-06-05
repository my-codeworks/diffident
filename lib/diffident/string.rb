module Diffident
  module StringDiffident
    def diff(old)
      Diffident.diff(self, old, Diffident.delimiter || "\n")
    end
    alias :- :diff
  end
end

String.class_eval do
  include Diffident::StringDiffident
end