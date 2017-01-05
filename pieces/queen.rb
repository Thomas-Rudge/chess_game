require_relative '../piece'

class Queen < Piece
  def valid_moves(positions = Array.new)
    empty1, enemy1, ally1 = *xy_nodes_from_position
    empty2, enemy2, ally2 = *verticle_nodes_from_position

    positions << empty1 + empty2
    positions << enemy1 + enemy2
    positions << ally1  + ally2

    positions
  end
end
