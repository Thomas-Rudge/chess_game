require_relative '../piece'

class King < Piece

  attr_writer :in_check

  def initialize(colour, position, boundary)
    @in_check = false
    super
  end

  def valid_moves
    moves = [1, 0, -1].product([-1, 0, 1])
    moves.map! do |m|
      if ((m[0] + @position[0]).between? *@boundary) && ((m[1] + @position[1]).between? *@boundary)
        [m[0] + @position[0], m[1] + @position[1]]
      end
    end.compact!

    moves -= [@position]
  end

  def in_check
    @in_check
  end

  alias_method :in_check?, :in_check

end
