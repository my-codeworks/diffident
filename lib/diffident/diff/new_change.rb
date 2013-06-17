class Diffident::Diff::NewChange
  
  attr_accessor :action, :base_row, :this_row, :text

  def initialize( args = {} )
    @action = args.fetch(:action)
    @base_row, @this_row = get_rows( args )
    @text = text
  end

private

  def get_rows( args )
    case @action
      when :same then
        return [ args.fetch(:rows).first, args.fetch(:rows).last ]
      when :addition then
        return [ -1, args.fetch(:row) ]
      when :deletion then
        return [ args.fetch(:row), -1 ]
    end
  end

end