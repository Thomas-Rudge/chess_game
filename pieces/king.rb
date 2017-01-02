require_relative '../piece'

class King < Piece

  attr_writer :in_check

  def initialize(colour, position, boundary, game)
    @in_check = false
    super
  end

  def valid_moves(positions = [[], []])
    [1, 0, -1].product([-1, 0, 1]).each do |m|
      val = [@position[0]+m[0], @position[1]+m[1]]

      if !@game.piece_in_position(val).nil? && val != @position
        positions[1] << val unless @game.piece_in_position(val).colour == @colour
      elsif (val[0].between? *@boundary) &&
            (val[1].between? *@boundary) &&
            val != @position
        positions[0] << val
      end
    end

    positions
  end

  def in_check?; @in_check end
end
