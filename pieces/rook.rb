require_relative '../piece'

class Rook < Piece
  def valid_moves
    xy_from_position
  end
end
