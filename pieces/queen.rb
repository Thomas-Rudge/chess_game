require_relative '../piece'

class Queen < Piece
  def valid_moves(positions = Array.new)
    valid1, take1 = *xy_nodes_from_position
    valid2, take2 = *verticle_nodes_from_position

    positions << valid1 + valid2
    positions << take1  + take2

    positions
  end
end
