module Diffident
  class Lexer

    require 'strscan'

    def initialize( args = {} )
      self.delimiter         = args.fetch(:delimiter, /\n/)
      self.input             = args.fetch(:input, [].each)
      self.input_has_raised  = false
      self.last_match_failed = false

      initialize_string_scanner
    end

    def next
      lexem_with_delimiter = string_scanner.scan_until(delimiter)
      if lexem_with_delimiter.nil?
        replenish_string_scanner_from_input
        if input_has_raised and string_scanner.eos?
          raise StopIteration
        elsif input_has_raised
          @latest_match = string_scanner.rest
          string_scanner.terminate
        else
          self.next()
        end
      else
        @latest_match = lexem_with_delimiter[/(.*)#{delimiter}/, 1]
      end
      @latest_match
    end

    def latest
      @latest_match
    end

    def has_more_lexems?
      !(input_has_raised and string_scanner.eos?)
    end

  private

    attr_reader :delimiter
    attr_reader :input
    attr_reader :input_has_raised
    attr_accessor :string_scanner
    attr_accessor :last_match_failed

    def delimiter=( value )
      @delimiter = Regexp.new( value )
    end

    def input=( enumerator )
      raise ArgumentError, "input must respond to .next()" unless enumerator.respond_to?(:next)
      @input = enumerator
    end

    def input_has_raised=(value)
      @input_has_raised = !!value
    end

    def initialize_string_scanner
      begin
        self.string_scanner = StringScanner.new( input.next )
      rescue StopIteration
        self.input_has_raised = true
        self.string_scanner = StringScanner.new( '' )
      end
    end

    def replenish_string_scanner_from_input
      begin
        rest = string_scanner ? string_scanner.rest : ''
        string_scanner.string= rest+input.next
        self.last_match_failed = false
      rescue StopIteration
        self.input_has_raised = true
      end
    end

  end
end