require_relative '../piece'

class Rook < Piece
  def valid_moves
    xy_nodes_from_position
  end
end
