require_relative '../piece'

class Pawn < Piece
  def valid_moves
    moves = Array.new
    direction = {0=>1, 1=>-1}

    moves << [@position[0], @position[1] + direction[@colour]]
    moves << [@position[0] - 1,  @position[1] + direction[@colour]]
    moves << [@position[0] + 1,  @position[1] + direction[@colour]]

    moves << [@position[0], @position[1] + direction[@colour] * 2] if @history.length == 1

    moves
  end
end
