module Board
  ATTR    = "1"
  BLACK   = "31"
  WHITE   = "34"
  PFX     = "\t"
  PLAYERS = {0=>"\033[#{ATTR};#{WHITE}mWhite\033[0m",
             1=>"\033[#{ATTR};#{BLACK}mBlack\033[0m"}
  UTFC    = {0=>{"King"    =>"\033[#{ATTR};#{WHITE}m\u265A",
                 "Queen"   =>"\033[#{ATTR};#{WHITE}m\u265B",
                 "Rook"    =>"\033[#{ATTR};#{WHITE}m\u265C",
                 "Bishop"  =>"\033[#{ATTR};#{WHITE}m\u265D",
                 "Knight"  =>"\033[#{ATTR};#{WHITE}m\u265E",
                 "Pawn"    =>"\033[#{ATTR};#{WHITE}m\u265F"},
             1=>{"King"    =>"\033[#{ATTR};#{BLACK}m\u265A",
                 "Queen"   =>"\033[#{ATTR};#{BLACK}m\u265B",
                 "Rook"    =>"\033[#{ATTR};#{BLACK}m\u265C",
                 "Bishop"  =>"\033[#{ATTR};#{BLACK}m\u265D",
                 "Knight"  =>"\033[#{ATTR};#{BLACK}m\u265E",
                 "Pawn"    =>"\033[#{ATTR};#{BLACK}m\u265F"},
             true =>"\033[40m",
             false=>"\033[47m"}

  def print_board(pieces)
    pieces = hashify_pieces(pieces)
    sign = [[" "," "," "," ","\033[1;34mL\033[0m"," "," "," "],
            [" "," "," "," ","\033[1;34mR\033[0m"," "," "," "]]

    print "\n\n"
    7.downto(0) do |y|
      print "#{PFX} #{sign[0].pop}  #{y} "
      0.upto(7) do |x|
        piece = pieces[[x, y]]
        piece = piece.nil? ? " " : UTFC[piece.colour][piece.class.to_s]
        print "#{UTFC[x.even? == y.even?]} #{piece} \033[0m"
      end
      print "  #{sign[1].pop}\n#{PFX}      "

      0.upto(7) do |x|
        print "#{UTFC[x.even? == y.even?]}   \033[0m"
      end
      print "\n"
    end

    print "#{PFX}       0  1  2  3  4  5  6  7\n\n"
  end

  def hashify_pieces(pieces, hash=Hash.new)
    # Creates a hash where the key is the board position,
    # and the value is the game piece at that position.
    [*(0..7)].product([*(0..7)]).each do |square|
      pieces.select { |p| !p.captured }.each { |p| hash[square] = p if p.position == square }
    end

    hash
  end

  def request_move(player, boundary, response=nil)
    puts  "#{PFX}Enter move for #{PLAYERS[player]}."
    print "#{PFX}>"
    response = gets.chomp.gsub(/[\[\]]/, "").downcase
  end

  def check_response(response, boundary)
    response = response.split(" ")
    response.map! { |x| x.split(",") }
    response.each { |x| x[0] = x[0].to_i ; x[1] = x[1].to_i }

    valid = response.length == 2
    response.each do |r|
      valid = false unless r.length == 2
      valid = false unless r.select { |x| x.between? *boundary }.length == 2
    end

    [response, valid]
  end

  def replay?
    puts  "#{PFX}Would you like to play again?"
    print "#{PFX}>"
    response = gets.chomp.downcase

    ["y", "yes", "ok"].include? response
  end

  def print_message(type, *args)
    case type
    when 0  then puts "Castling is not possible at this time."
    when 1  then puts "That move is not valid."
    when 2  then puts "There is nothing in square #{args[0]}."
    when 3  then puts "You cannot move an opponents piece."
    when 4  then puts "That is not a valid move for a #{args[0]}."
    when 5  then puts "One or more pieces are blocking that move."
    when 6  then puts "Pawns move forward and capture diagonally."
    when 7  then puts "You cannot take your own #{args[0]}."
    when 8  then puts "You cannot place your King in check."
    when 9  then puts "The #{PLAYERS[args[0]]} King is in check!"
    when 10 then puts "Checkmate! Player #{PLAYERS[args[0]]} wins!"
    when 11 then puts "Stalemate! It's a draw.'"
    else         puts "Unknown message type: #{type}"
    end
  end

  def clear_screen
    RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i ? system("cls") : system("clear")
  end
end


