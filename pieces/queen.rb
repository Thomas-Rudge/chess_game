require_relative '../piece'

class Queen < Piece
  def valid_moves
    moves = Array.new
    moves += xy_nodes_from_position
    moves += verticle_nodes_from_position
  end
end
