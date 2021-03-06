require_relative '../piece'

class King < Piece

  attr_writer :in_check

  def initialize(colour, position, boundary, game)
    @in_check = false
    super
  end

  def valid_moves(positions = [[], [], []])
    [1, 0, -1].product([-1, 0, 1]).each do |m|
      val = [@position[0]+m[0], @position[1]+m[1]]

      piece = @game.piece_in_position(val)
      if piece && val != @position
        piece.colour == @colour ? positions[2] << val : positions[1] << val
      elsif (val_in_bounds? val) && val != @position
        positions[0] << val
      end
    end

    positions
  end

  def available?; false end

  def in_check?; @in_check end
end
