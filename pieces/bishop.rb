require_relative '../piece'

class Bishop < Piece
  def valid_moves
    verticles_from_position
  end
end
