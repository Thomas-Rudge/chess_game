class Piece

  attr_accessor :position
  attr_reader   :colour

  def initialize(colour, position)
    @colour   = colour
    @position = position
  end

  def callout(position)
    return self if position == @position
  end
end
