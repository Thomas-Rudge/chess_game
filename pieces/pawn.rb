require_relative '../piece'

class Pawn < Piece
  def valid_moves(positions = [[], [], []])
    direction = {0=>1, 1=>-1}

    moves = Array.new

    moves << [@position[0],     @position[1] + direction[@colour]]
    moves << [@position[0] - 1, @position[1] + direction[@colour]]
    moves << [@position[0] + 1, @position[1] + direction[@colour]]
    moves << [@position[0],     @position[1] + direction[@colour] * 2] if @history.empty?

    moves.each do |move|
      piece = @game.piece_in_position(move)
      if !piece.nil?
        unless move[0] == @position[0]
          piece.colour == @colour ? positions[2] << move : positions[1] << move
        end
      elsif (move[0].between? *@boundary) &&
            (move[1].between? *@boundary) &&
             move[0] == @position[0]
        if (move[1] - @position[1]).abs > 1
          positions[0] << move if (positions[0].include? [move[0], move[1] + direction[@colour^1]])
        else
          positions[0] << move
        end
      end
    end

    positions
  end
end
