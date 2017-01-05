require_relative '../piece'

class Knight < Piece
  def valid_moves(positions = [[], [], []])
    [-1, -2, 2, 1].product([-1, -2, 2, 1]).select { |x| x[0].abs != x[1].abs }.each do |val|
      move = [val[0] + @position[0], val[1] + @position[1]]

      piece = @game.piece_in_position(val)
      if !piece.nil?
        piece.colour == @colour ? positions[2] << val : positions[1] << val
      elsif (val[0].between? *@boundary) && (val[1].between? *@boundary)
        positions[0] << val
      end
    end

    positions
  end
end
