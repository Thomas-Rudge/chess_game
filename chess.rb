Dir["pieces/*.rb"].each { |file| require_relative file }
require_relative 'game_logic'

class Game
  include GameLogic

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

  #private

  def reposition
    @game_pieces.each { |p| p.reset }
    @captured_pieces.clear
  end

  def reset_game_history
    @game_pieces.each { |p| p.clear_history }
    @turn = 0
  end
########### C A S T L I N G ###############################################
  def attempt_castling(corner)
    # Performs castling move with a rook and king. corner either :r or :l
    # 1. The king and rook involved in castling must not have previously moved;
    # 2. The king and the rook must be on the same rank.
    # 3. The king may not currently be in check.
    king, rook = get_rook_and_king(corner)
    return -1 if rook.nil? || king.nil?
    # 3. There must be no pieces between the king and the rook;
    range = range_between_pieces(rook.position, king.position)
    return -1 unless piece_in_range(range).empty?
    # 4. The king may not pass through
    #    or end up in a square that is under attack by an enemy piece (though the
    #    rook is permitted to be under attack and to pass over an attacked square);

  end

  def get_rook_and_king(corner)
    # Returns the king and rook that can be used for castling
    king  = @game_pieces.select { |p| (p.is_a? King) && p.colour == @turn }
    rooks = @game_pieces.select { |r| (r.is_a? Rook) && p.colour == @turn }

    if corner == :r
      rook = rooks.select { |r| r.position[0] == @boundary[1] }
    else
      rook = rooks.select { |r| r.position[0] == @boundary[0] }
    end

    rook = nil unless rook.history.length.empty? && !rook.captured?
    king = nil unless king.history.length.empty? && !king.in_check?

    [king, rook]
  end

  def range_between_pieces(a, b)
    # returns the range between a & b. The returned range excludes a and b.
    a, b = *[a, b].sort
    temp_a    = Piece.new(0, a, @boundary)
    in_range1 = Proc.new { |x| (x[0].between? a[0], b[0]) && (x[1].between? a[1], b[1]) }
    in_range2 = Proc.new { |x| (x[0].between? a[0], b[0]) && (x[1].between? b[1], a[1]) }

    range =
      case # From the perspective of "a"
      when a[0] == b[0]                then (temp_a.y_axes).select!                &in_range1
      when a[1] == b[1]                then (temp_a.x_axes).select!                &in_range1
      when a[0] <  b[0] && a[1] < b[1] then (temp_a.upper_right_verticles).select! &in_range1
      when a[0] <  b[0] && a[1] > b[1] then (temp_a.lower_right_verticles).select! &in_range2
      end

    range -= [a, b]
  end

  def piece_in_range(range, pieces = Array.new)
    # returns the game pieces found in a range, or nil
    range.each do |r|
      val = piece_in_position(r)
      pieces << val unless val.nil?
    end

    pieces
  end

  def piece_in_position(position)
    # returns any game pieces found in position, or nil
    @game_pieces.each do |p|
      val = p.callout(position)
      return val unless val.nil?
    end; nil
  end
  #### C h E C K   K I N G   S T A T U S ###########################
  def check_status_of_kings
    kings = @game_pieces.select { |p| (p.is_a? King) }

    kings.each do |k|
      in_check = false

      @game_pieces.each do |p|
        next unless p.colour != k.colour
        next if p.captured?

        moves = p.valid_moves
        next unless moves.include? k.position
        # //TODO Need special case for pawn
        if p.is_a? Knight # can jump
          in_check = true
        else # Check there is nothing in the way
          range = range_between_pieces(p.position, k.position)
          in_check = true if piece_in_range(range).empty?
        end
      end

      k.in_check = in_checl
    end
  end
end
