require_relative '../piece'

class Knight < Piece
  def valid_moves
    moves = Array.new
    [-1, -2, 2, 1].product([-1, -2, 2, 1]).select { |x| x[0].abs != x[1].abs }.each do |move|
      move = [move[0] + @position[0], move[1] + @position[1]]
      moves << move if (move[0].between? *@boundary) && (move[1].between? *@boundary)
    end

    moves
  end
end
