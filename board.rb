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
    7.downto(0) do |y|
      print "#{PFX}#{y} "
      0.upto(7) do |x|
        p = pieces[[x, y]]
        p = p.nil? ? " " : UTFC[p.colour][p.class.to_s]
        print "#{UTFC[x.even? == y.even?]} #{p} \033[0m"
      end
      print "\n#{PFX}  "
      0.upto(7) do |x|
        print "#{UTFC[x.even? == y.even?]}   \033[0m"
      end
      print "\n"
    end

    print "#{PFX}   0  1  2  3  4  5  6  7"
  end

  def hashify_pieces(pieces, hash=Hash.new)
    # Creates a hash where the key is the board position,
    # and the value is the game piece at that position.
    [*(0..7)].product([*(0..7)]).each do |square|
      pieces.each { |p| hash[square] = p if p.position == square }
    end

    hash
  end

  def print_winner(player)
    puts "#{PFX}Checkmate! #{PLAYERS[player]} wins!"
  end

  def request_move(player, boundary, response=nil)
    puts "#{PFX}Enter move for #{PLAYERS[player]}."
    print "#{PFX}>"
    response = gets.chomp.gsub(/[\[\]]/,"").downcase
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

  def ask_replay
    puts  "#{PFX}Would you like to play again?"
    print "#{PFX}>"
    response = gets.chomp.downcase

    return (["y", "yes", "ok"].include? response) ? true : false
  end

  def clear_screen
    RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i ? system("cls") : system("clear")
  end
end


