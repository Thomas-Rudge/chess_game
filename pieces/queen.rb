require_relative '../piece'

class Queen < Piece
  def valid_moves
    moves = Array.new
    moves += xy_from_position
    moves += verticles_from_position
  end
end
