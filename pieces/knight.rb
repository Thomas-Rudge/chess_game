require_relative '../piece'

class Knight < Piece
  def valid_moves(positions = [[], []])
    [-1, -2, 2, 1].product([-1, -2, 2, 1]).select { |x| x[0].abs != x[1].abs }.each do |move|
      move = [move[0] + @position[0], move[1] + @position[1]]

      if !@game.piece_in_position(move).nil?
        positions[1] << move unless @game.piece_in_position(move).colour == @colour
      elsif (move[0].between? *@boundary) && (move[1].between? *@boundary)
        positions[0] << move
      end
    end

    positions
  end
end
