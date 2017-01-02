require_relative '../piece'

class Pawn < Piece
  def valid_moves(positions = [[], []])
    direction = {0=>1, 1=>-1}

    moves = Array.new

    moves << [@position[0],     @position[1] + direction[@colour]]
    moves << [@position[0] - 1, @position[1] + direction[@colour]]
    moves << [@position[0] + 1, @position[1] + direction[@colour]]
    moves << [@position[0],     @position[1] + direction[@colour] * 2] if @history.empty?

    moves.each do |p|
      if !@game.piece_in_position(p).nil?
        positions[1] << p unless p[0] == @position[0] ||
                                 @game.piece_in_position(p).colour == @colour
      elsif (p[0].between? *@boundary) && (p[1].between? *@boundary)
        positions[0] << p
      end
    end

    positions
  end
end
