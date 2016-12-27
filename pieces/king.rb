require_relative '../piece'

class King < Piece
  def valid_moves
    moves = [1, 0, -1].product([-1, 0, 1])
    moves.map! do |m|
      if ((m[0] + @position[0]).between? 0, 7) && ((m[1] + @position[1]).between? 0, 7)
        [m[0] + @position[0], m[1] + @position[1]]
      end
    end.compact!

    moves -= [@position]
  end
end
