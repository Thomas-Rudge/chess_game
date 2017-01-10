require_relative '../piece'

class Pawn < Piece
  def valid_moves(positions = [[], [], []], moves = Array.new)
    one_step = {0=>1, 1=>-1}

    moves << [@position[0],     @position[1] + one_step[@colour]]
    moves << [@position[0] - 1, @position[1] + one_step[@colour]]
    moves << [@position[0] + 1, @position[1] + one_step[@colour]]
    moves << [@position[0],     @position[1] + one_step[@colour] * 2] if @history.empty?

    moves.each do |move|
      piece = @game.piece_in_position(move)
      if piece
        unless move[0] == @position[0]
          piece.colour == @colour ? positions[2] << move : positions[1] << move
        end
      elsif (val_in_bounds? move) && move[0] == @position[0]
        if (move[1] - @position[1]).abs > 1
          # Only include the two steps forward move, if the one step forward was included
          positions[0] << move if (positions[0].include? [move[0], move[1] + one_step[@colour^1]])
        else
          positions[0] << move
        end
      end
    end

    positions
  end
end
