Dir["pieces/*.rb"].each { |file| require_relative file }
require_relative 'board'

class Game
  include Board

  attr_accessor :game_pieces, :turn
  attr_writer :checkmate, :stalemate

  def initialize(*args)
    @game_pieces     = Array.new
    @boundary        = [0, 7]
    @turn            = 0 # corresponds with Piece @colour
    @checkmate       = false
    @stalemate       = false

    setup unless args.include? "empty"
  end

  def setup
    @game_pieces.clear

    [0, 1].each do |colour| # 0 - White, 1 - Black
      @game_pieces << Rook.new(  colour, [0, @boundary[colour]], @boundary, self)
      @game_pieces << Knight.new(colour, [1, @boundary[colour]], @boundary, self)
      @game_pieces << Bishop.new(colour, [2, @boundary[colour]], @boundary, self)
      @game_pieces << Queen.new( colour, [3, @boundary[colour]], @boundary, self)
      @game_pieces << King.new(  colour, [4, @boundary[colour]], @boundary, self)
      @game_pieces << Bishop.new(colour, [5, @boundary[colour]], @boundary, self)
      @game_pieces << Knight.new(colour, [6, @boundary[colour]], @boundary, self)
      @game_pieces << Rook.new(  colour, [7, @boundary[colour]], @boundary, self)
      # Add the pawns
      8.times { |i| @game_pieces << Pawn.new(colour, [i, (@boundary[colour]-1).abs], @boundary, self) }
    end
  end

  def start
    until checkmate? || stalemate?
      clear_screen
      print_board(@game_pieces)
      take_turns
      pawn_promotion
      check_game_state
    end

    clear_screen
    print_board(@game_pieces)
    checkmate? ? print_message(10, @turn^1) : print_message(11)
    ask_replay ? restart : finish
  end

  def restart
    reposition
    reset_game_history
  end

  def reposition
    @game_pieces.each { |p| p.reset }
  end

  def reset_game_history
    @game_pieces.each { |p| p.clear_history }
    @turn = 0
    @checkmate = false
    @stalemate = false
  end

  def take_turns
    loop do
      # Get a response from the player
      move = request_move(@turn, @boundary)
      finish if ["q", "quit", "exit"].include? move
      # Check if castling
      if ["cl", "cr"].include? move
        castled = attempt_castling(move[1].to_sym)
        unless castled
          print_message(0)
          next
        end
        break
      end
      # If the response isn't in a valid format "1,2 3,4", then reject it.
      move = check_response(move, @boundary)
      if move[1] == false
        print_message(1)
        next
      else
        move = move[0]
      end
      # Check that there is a piece in the first position,
      # and that the player is permitted to move it.
      to_move = piece_in_position(move[0])
      move_to = piece_in_position(move[1])

      next unless piece_movable?(to_move, move[0])
      next unless move_valid?(to_move, move_to, move[0], move[1])
      # Move and capture as required
      move_to.captured = true unless move_to.nil?
      to_move.position = move[1]
      # Get the players king and make sure he wasn't put in check
      king = update_status_of_kings.select { |k| k.colour == @turn }[0]
      if king.in_check?
        2.times { to_move.history.pop }
        to_move.position = move[0]
        move_to.captured = false unless move_to.nil?
        update_status_of_kings
        print_message(8)
        next
      end

      break
    end

    @turn ^= 1
  end
########### M O V E   L O G I C ################################
  def move_valid?(mover, target, from, to)
    response = true
    case
    # Check that the target square is a valid move for the piece
    when (!mover.valid_moves.flatten(1).include? to)
      print_message(4, mover.class.to_s)
      response = false
    # Check whether a user is trying to take their own colour
    when (!target.nil? && target.colour == @turn)
      print_message(7, target.class.to_s)
      response = false
    end

    response
  end

  def piece_movable?(piece, move)
    case
    when piece.nil?            then print_message(2, move) ; false
    when piece.colour != @turn then print_message(3)       ; false
    else                                                     true
    end
  end

  def get_attackers_of_position(position, turn, attackers = Array.new, direction = {1=>1, 0=>-1})
    @game_pieces.select { |p| p.colour != turn && !p.captured? }.each do |piece|
      if piece.is_a? Pawn
        attackers << piece if (position[0] - piece.position[0] == direction[turn]   &&
                               position[1] - piece.position[1] == direction[turn])  ||
                              (position[0] - piece.position[0] == direction[turn^1] &&
                               position[1] - piece.position[1] == direction[turn])
      else
        attackers << piece if piece.valid_moves.flatten(1).include? position
      end
    end

    attackers
  end

  def position_under_attack?(position)
    !get_attackers_of_position(position, @turn).empty?
  end

  def pawn_promotion
    @game_pieces.select { |p| (p.is_a? Pawn) && !p.captured? }.each do |pawn|
      if (pawn.colour == 0 && pawn.position[1] == @boundary[1]) ||
         (pawn.colour == 1 && pawn.position[1] == @boundary[0])
        pawn.captured = true
        @game_pieces << Queen.new(pawn.colour, pawn.position, @boundary, self)
      end
    end
  end

  def all_valid_moves(king, all_moves = Array.new)
    # Returns all squares that non-king pieces could be moved to without exposing the king
    ally_pieces = @game_pieces.select { |p| p.available? }

    ally_pieces.each do |piece|
      piece.valid_moves[0, 1].flatten(1).each do |move|
        next if move.nil?
        all_moves << move unless does_move_expose_king?(piece, move, king)
      end
    end

    all_moves
  end

  def all_kings_moves(king, nope = Array.new)
    moves = king.valid_moves[0, 1].flatten(1)
    moves.each { |m| nope << m unless get_attackers_of_position(m, king.colour).empty?}

    moves - nope
  end

#### C H E C K M A T E   L O G I C #########################
  def check_game_state
    king = get_kings.select { |k| k.colour == @turn }[0]

    case king.in_check?
    when true
      king_is_alone = @game_pieces.count { |p| p.available? } == 0
      # Can the king move out of the way
      king_can_move = !all_kings_moves(king).empty?

      if king_can_move
        return
      elsif king_is_alone
        @checkmate = true
        return
      end

      attacker = get_attackers_of_position(king.position, @turn)

      unless attacker.length > 1
        attacker = attacker[0]
        # See if the user can capture the attacker
        @game_pieces.select { |p| p.available? }.each do |piece|
          return if piece.valid_moves[1].include? attacker.position
        end
        # See if the user can block the attacker
        unless (attacker.is_a? Knight) || (attacker.is_a? Pawn)
          attack_range = range_between_squares(attacker.position, king.position)

          game_pieces.select { |p| p.available? }.each do |piece|
            moves = piece.valid_moves[0]
            return if attack_range.length > (attack_range - moves).length
          end
        end
      end

      @checkmate = true

    when false
      @stalemate = true if all_kings_moves(king).empty? && all_valid_moves(king).empty?
    end
  end

  def does_move_expose_king?(piece, move, king, result=false)
    captured_piece = piece_in_position(move)
    captured_piece.captured = true unless captured_piece.nil?
    return_position = piece.position
    piece.position  = move

    update_status_of_kings

    result = true if king.in_check?

    piece.position = return_position
    2.times { piece.history.pop }
    captured_piece.captured = false unless captured_piece.nil?

    result
  end
########### C A S T L I N G ###############################################
  def attempt_castling(corner)
    # Performs castling move with a rook and king. corner either :r or :l
    # 1. The king and rook involved in castling must not have previously moved;
    # 2. The king and the rook must be on the same rank.
    # 3. The king may not currently be in check.
    king, rook = get_rook_and_king_for_castling(corner)
    return false if rook.nil? || king.nil?
    # 3. There must be no pieces between the king and the rook;
    return false unless pieces_in_range(rook.position, king.position).empty?
    # 4. The king cannot move to a square under attack (i.e move into check)
    # 5. The king may not pass through a square under attack
    range_between_squares(rook.position, king.position).each do |position|
      next if position[0] < 2 # For castling to the left
      return false unless get_attackers_of_position(position, @turn).empty?
    end

    case corner
    when :l
      king.position = [2, king.position[1]]
      rook.position = [3, rook.position[1]]
    when :r
      king.position = [6, king.position[1]]
      rook.position = [5, rook.position[1]]
    end; true
  end

  def get_rook_and_king_for_castling(corner)
    corner = {:r=>@boundary[1], :l=>@boundary[0]}[corner]

    king  = get_kings.select { |k| (k.is_a? King)     &&
                                    k.colour == @turn &&
                                    k.history.empty?  &&
                                   !k.in_check? }[0]

    rook = @game_pieces.select { |r| (r.is_a? Rook)    &&
                                      r.available?     &&
                                      r.history.empty? &&
                                      r.position[0] == corner }[0]

    [king, rook]
  end

  def range_between_squares(a, b)
    # returns the range between a & b. The returned range excludes a and b.
    a, b = *[a, b].sort
    temp_g    = Game.new("empty")
    temp_a    = Piece.new(0, a, @boundary, temp_g)
    in_range1 = Proc.new { |x| (x[0].between? a[0], b[0]) && (x[1].between? a[1], b[1]) }
    in_range2 = Proc.new { |x| (x[0].between? a[0], b[0]) && (x[1].between? b[1], a[1]) }

    range =
      case # From the perspective of "a"
      when a[0] == b[0]                then (temp_a.y_axes[0]).select                &in_range1
      when a[1] == b[1]                then (temp_a.x_axes[0]).select                &in_range1
      when a[0] <  b[0] && a[1] < b[1] then (temp_a.upper_right_verticles[0]).select &in_range1
      when a[0] <  b[0] && a[1] > b[1] then (temp_a.lower_right_verticles[0]).select &in_range2
      end

    range -= [a, b]
  end

  def pieces_in_range(a, b, pieces = Array.new)
    # returns the game pieces found in a range, or nil
    range = range_between_squares(a, b)

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
      return val unless val.nil? || val.captured?
    end; nil
  end
  #### U P D A T E   K I N G   S T A T U S ###########################
  def update_status_of_kings
    # Checks and updates the status of both kings, then returns them
    get_kings.each do |k|
      k.in_check = !get_attackers_of_position(k.position, k.colour).empty?
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
  def stalemate?; @stalemate end
end
