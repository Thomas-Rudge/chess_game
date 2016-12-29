require_relative '../piece'

class Bishop < Piece
  def valid_moves
    verticle_nodes_from_position
  end
end
