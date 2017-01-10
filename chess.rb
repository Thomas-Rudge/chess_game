Dir["pieces/*.rb"].each { |file| require_relative file }
require_relative 'board'

class Game
  include Board

  attr_accessor :game_pieces, :turn, :available_pieces
  attr_writer :checkmate, :stalemate

  def initialize(*args)
    @game_pieces      = Array.new
    @boundary         = [0, 7]
    @turn             = 0 # corresponds with Piece @colour
    @checkmate        = false
    @stalemate        = false
    @available_pieces = Array.new

    setup unless args.include? "empty"

    game = self
    @game_pieces.define_singleton_method(:<<) do |val|
      self.push(val)
      game.update_available_pieces
      self[-1]
    end
  end

  def setup
    @game_pieces.clear

    [0, 1].each do |colour| # 0 - White, 1 - Black
      @game_pieces.push(
        Rook.new(  colour, [0, @boundary[colour]], @boundary, self),
        Knight.new(colour, [1, @boundary[colour]], @boundary, self),
        Bishop.new(colour, [2, @boundary[colour]], @boundary, self),
        Queen.new( colour, [3, @boundary[colour]], @boundary, self),
        King.new(  colour, [4, @boundary[colour]], @boundary, self),
        Bishop.new(colour, [5, @boundary[colour]], @boundary, self),
        Knight.new(colour, [6, @boundary[colour]], @boundary, self),
        Rook.new(  colour, [7, @boundary[colour]], @boundary, self)
      )
      # Add the pawns
      8.times { |i| @game_pieces.push Pawn.new(colour, [i, (@boundary[colour]-1).abs], @boundary, self) }
    end

    update_available_pieces
  end

  def start
    until checkmate? || stalemate?
      clear_screen
      print_board(@game_pieces)
      take_turns
      pawn_promotion
      update_status_of_kings
      update_game_state
    end

    clear_screen
    print_board(@game_pieces)
    checkmate? ? print_message(10, @turn^1) : print_message(11)
    replay? ? restart : finish
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
      move = request_move(@turn, @boundary)
      finish if ["q", "quit", "exit"].include? move

      if ["cl", "cr"].include? move # Check if castling
        castled = attempt_castling(move[1].to_sym)
        unless castled
          print_message(0)
          next
        end
        break
      end

      move = format_response(move)
      unless user_response_valid? move
        print_message(1)
        next
      end

      move_from = piece_in_position(move[0])
      move_to   = piece_in_position(move[1])
      next unless piece_movable?(move_from, move)

      if move_to && !move_to.takable?
        print_message(7, target.class.to_s)
        next
      end

      king = get_kings.select { |k| k.colour == @turn }[0]
      if does_move_expose_king?(move_from, move[1], king)
        print_message(8)
        next
      end

      make_move(move_from, move_to, move)

      break
    end

    @turn ^= 1
  end
########### M O V E   L O G I C ################################
  def make_move(mover, target, move)
    target.captured = true unless target.nil?
    mover.position  = move[1]
  end

  def move_valid?(mover, new_position)
    mover.valid_moves.flatten(1).include? new_position
  end

  def piece_movable?(piece, move)
    case
    when piece.nil?
      print_message(2, move[0])
    when piece.colour != @turn
      print_message(3)
    when !(piece.valid_moves[0, 2].flatten(1).include? move[1])
      print_message(4, piece.class.to_s)
    else
      return true
    end

    return false
  end

  def get_attackers_of_position(position, turn, attackers = Array.new)
    direction = {1=>1, 0=>-1}

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

  def all_valid_moves(king)
    # Returns all squares that non-king pieces could be moved to without exposing the king
    all_moves   = Array.new

    @available_pieces.each do |piece|
      piece.valid_moves[0, 2].flatten(1).each do |move|
        all_moves << move unless does_move_expose_king?(piece, move, king)
      end
    end

    all_moves
  end

  def all_kings_moves(king, nope = Array.new)
    moves = king.valid_moves[0, 2].flatten(1)
    moves.each { |m| nope << m unless get_attackers_of_position(m, king.colour).empty?}

    moves - nope
  end

#### C H E C K M A T E   L O G I C #########################
  def update_game_state
    king = get_kings.select { |k| k.colour == @turn }[0]

    case king.in_check?
    when true
      king_is_alone = @available_pieces.length == 0
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
        return if attacker_can_be_captured_or_blocked?(attacker, king.position)
      end

      @checkmate = true

    when false
      @stalemate = true if all_kings_moves(king).empty? && all_valid_moves(king).empty?
    end
  end

  def attacker_can_be_captured_or_blocked?(attacker, kings_position)
    attack_range = range_between_squares(attacker.position, kings_position)

    @available_pieces.each do |piece|
      moves = piece.valid_moves
      return true if moves[1].include? attacker.position
      return true if attack_range.length > (attack_range - moves[0]).length
    end ; false
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

    update_status_of_kings

    result
  end

  def update_available_pieces
    @available_pieces = @game_pieces.select { |p| p.available? } ; nil
  end
########### C A S T L I N G ###############################################
  def attempt_castling(corner)
    # Performs castling move with a rook and king. corner either :r or :l
    # 1. The king and rook involved in castling must not have previously moved;
    # 2. The king and the rook must be on the same rank.
    # 3. The king may not currently be in check.
    # 3. There must be no pieces between the king and the rook;
    # 4. The king cannot move to a square under attack (i.e move into check)
    # 5. The king may not pass through a square under attack
    king, rook = get_rook_and_king_for_castling(corner)

    return false if rook.nil? || king.nil?
    return false unless pieces_in_range(rook.position, king.position).empty?
    return false unless path_clear_for_castling?(rook, king)

    perform_castling(rook, king, corner)
  end

  def perform_castling(rook, king, corner)
    case corner
    when :l
      king.position = [2, king.position[1]]
      rook.position = [3, rook.position[1]]
    when :r
      king.position = [6, king.position[1]]
      rook.position = [5, rook.position[1]]
    end ; true
  end

  def path_clear_for_castling?(rook, king)
    range_between_squares(rook.position, king.position).each do |position|
      next if position[0] < 2 # For castling to the left
      return false unless get_attackers_of_position(position, @turn).empty?
    end ; true
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
  ###### R E S P O N S E #########
  def format_response(response)
    response = response.match /\d,\d \d,\d/

    unless response.nil?
      response = response.string.split(" ")
      response.map! { |r| r.split(",").tap{ |x| x[0] = x[0].to_i ; x[1] = x[1].to_i } }
    end

    response
  end

  def user_response_valid?(response)
    return false if response.nil?

    response.each do |r|
      return false unless (r[0].between? *@boundary) && (r[1].between? *@boundary)
    end ; true
  end
  ###### S E T T E R S   &    G E T T E R S #####################
  def checkmate?; @checkmate end
  def stalemate?; @stalemate end

  def turn=(value)
    @turn = value
    update_available_pieces
  end
end
