Dir["pieces/*.rb"].each { |file| require_relative file }

class Game

  attr_reader :game_pieces, :captured_pieces

  def initialize
    @game_pieces     = Array.new
    @captured_pieces = Array.new
    @boundary        = [0, 7]
    @turn            = 0 # corresponds with Piece @colour

    setup
  end

  def setup
    @game_pieces.clear

    [0, 1].each do |colour| # 0 - White, 1 - Black
      @game_pieces << Rook.new(  colour, [0, @boundary[colour]], @boundary)
      @game_pieces << Knight.new(colour, [1, @boundary[colour]], @boundary)
      @game_pieces << Bishop.new(colour, [2, @boundary[colour]], @boundary)
      @game_pieces << Queen.new( colour, [3, @boundary[colour]], @boundary)
      @game_pieces << King.new(  colour, [4, @boundary[colour]], @boundary)
      @game_pieces << Bishop.new(colour, [5, @boundary[colour]], @boundary)
      @game_pieces << Knight.new(colour, [6, @boundary[colour]], @boundary)
      @game_pieces << Rook.new(  colour, [7, @boundary[colour]], @boundary)
      # Add the pawns
      8.times { |i| @game_pieces << Pawn.new(colour, [i, (@boundary[colour]-1).abs], @boundary) }
    end
  end

  def start

  end

  def restart
    reposition
    reset_game_history
  end

  def castling(corner)
    # Performs castling move with a rook and king. corner either :r or :l
    king, rook = get_rook_and_king(corner)

    return -1 if rook.nil? || king.nil?
    # 2. There must be no pieces between the king and the rook;

    # 3. The king may not currently be in check, nor may the king pass through
    #    or end up in a square that is under attack by an enemy piece (though the
    #    rook is permitted to be under attack and to pass over an attacked square);
    # 4. The king and the rook must be on the same rank.

  end

  private

  def get_rook_and_king(corner)
    # Returns the king and rook that can be used for castling
    king  = @game_pieces.select { |p| (p.is_a? King) && p.colour == @turn }
    rooks = @game_pieces.select { |r| (r.is_a? Rook) && p.colour == @turn }
    # 1. The king and rook involved in castling must not have previously moved;
    if corner == :r
      rook = rooks.select { |r| r.position[0] == @boundary[1] }
    else
      rook = rooks.select { |r| r.position[0] == @boundary[0] }
    end

    rook = nil if rook.history.length > 1 || rook.captured?
    king = nil if king.history.length > 1

    [king, rook]
  end

  def piece_between_points(a, b)
    # returns the first game piece found between two points on a board

  end

  def reposition
    @game_pieces.each { |p| p.reset }
    @captured_pieces.clear
  end

  def reset_game_history
    @game_pieces.each { |p| p.clear_history }
    @turn = 0
  end
end
