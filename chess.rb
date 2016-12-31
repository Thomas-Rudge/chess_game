Dir["pieces/*.rb"].each { |file| require_relative file }
require_relative 'board'

class Game
  include Board

  attr_reader :game_pieces, :captured_pieces
  attr_writer :checkmate

  def initialize
    @game_pieces     = Array.new
    @captured_pieces = Array.new
    @boundary        = [0, 7]
    @turn            = 0 # corresponds with Piece @colour
    @checkmate       = false

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
    until checkmate?
      clear_screen
      print_board(@game_pieces)
      take_turns
    end

    print_winner(@turn^1)
    ask_replay ? restart : finish
  end

  def restart
    reposition
    reset_game_history
  end

  def reposition
    @game_pieces.each { |p| p.reset }
    @captured_pieces.clear
  end

  def reset_game_history
    @game_pieces.each { |p| p.clear_history }
    @turn = 0
  end

  def take_turns
    # Goes through the logic of each turn. It's a bit of a long method :/
    loop do
      # Get a response from the player
      move = request_move(@turn, @boundary)
      finish if ["q", "quit", "exit"].include? move
      # If the response isn't in a valid format "1,2 3,4", then reject it.
      move = check_response(move, @boundary)
      if move[1] == false
        puts "That move is not valid."
        next
      else
        move = move[0]
      end
      # Check that there is a piece in the first position,
      # and that the player is permitted to move it.
      to_move = piece_in_position(move[0])
      if to_move.nil?
        puts "There is nothing in square #{move[0]}."
        next
      elsif to_move.colour != @turn
        puts "That is not your piece to move."
        next
      end
      # Check that the target square is a valid move for the piece
      unless to_move.valid_moves.include? move[1]
        puts "That is not a valid move for a #{to_move.class}."
        next
      end
      # Check there is nothing blocking the move, unless it's a knight.
      unless to_move.class == Knight
        move_range = range_between_pieces(*move)
        in_way = pieces_in_range(move_range)
        if !in_way.empty?
          puts "One or more pieces are blocking that move."
          next
        end
      end
      # Check whether a piece is being taken
      move_to = piece_in_position(move[1])
      if move_to.nil?
        if (to_move.is_a? Pawn) && move[0][0] != move[1][0]
          puts "Pawns move forward and capture diagonally."
          next
        end
      else
        if move_to.colour == @turn
          puts "You cannot take your own #{move_to.class}."
          next
        else
          if to_move.is_a? Pawn
            if move_to.position[0] == to_move.position[0]
              puts "Pawns move forward and capture diagonally."
              next
            end
          end
          move_to.captured = true
          captured_pieces << move_to
        end
      end

      to_move.position = move[1]
      @turn ^= 1
      break
    end
  end
########### M O V E   L O G I C ################################

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
    return -1 unless pieces_in_range(range).empty?
    # 4. The king may not pass through
    #    or end up in a square that is under attack by an enemy piece (though the
    #    rook is permitted to be under attack and to pass over an attacked square);

    case corner
    when :l
      king.position = [2, king.position[1]]
      rook.position = [3, rook.position[1]]
    when :r
      king.position = [6, king.position[1]]
      rook.position = [5, rook.position[1]]
    end
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

  def pieces_in_range(range, pieces = Array.new)
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
  #### U P D A T E   K I N G   S T A T U S ###########################
  def update_status_of_kings
    # Checks and updates the status of both kings, then returns them
    kings = get_kings

    kings.each do |k|
      in_check = false

      @game_pieces.each do |p|
        next unless p.colour != k.colour
        next if p.captured?

        moves = p.valid_moves
        next unless moves.include? k.position

        if p.is_a? Knight # can jump
          in_check = true
        elsif (p.is_a? Pawn) && p.position[0] == k.position[0]
          next
        else # Check there is nothing in the way
          range = range_between_pieces(p.position, k.position)
          in_check = true if pieces_in_range(range).empty?
        end
      end

      k.in_check = in_check
    end
  end

  def get_kings
    @game_pieces.select { |p| (p.is_a? King) }
  end

  def finish
    exit
  end
  ###### G E T T E R S #####################
  def checkmate?; @checkmate end
end
