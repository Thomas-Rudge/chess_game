

module Board
  ATTR  = "1"
  BLACK = "31"
  WHITE = "34"
  UTFC = {0=>{King    =>"\033[#{ATTR};#{WHITE}m\u265A",
              Queen   =>"\033[#{ATTR};#{WHITE}m\u265B",
              Rook    =>"\033[#{ATTR};#{WHITE}m\u265C",
              Bishop  =>"\033[#{ATTR};#{WHITE}m\u265D",
              Knight  =>"\033[#{ATTR};#{WHITE}m\u265E",
              Pawn    =>"\033[#{ATTR};#{WHITE}m\u265F"},
          1=>{King    =>"\033[#{ATTR};#{BLACK}m\u265A",
              Queen   =>"\033[#{ATTR};#{BLACK}m\u265B",
              Rook    =>"\033[#{ATTR};#{BLACK}m\u265C",
              Bishop  =>"\033[#{ATTR};#{BLACK}m\u265D",
              Knight  =>"\033[#{ATTR};#{BLACK}m\u265E",
              Pawn    =>"\033[#{ATTR};#{BLACK}m\u265F"},
          true =>"\033[40m",
          false=>"\033[47m"}

  PFX = "\t"

  def print_board(pieces)
    pieces = hashify_pieces(pieces)
    7.downto(0) do |y|
      print "#{PFX}#{y} "
      0.upto(7) do |x|
        p = pieces[[x, y]]
        p = p.nil? ? " " : UTFC[p.colour][p.class]
        print "#{UTFC[x.even? == y.even?]} #{p} \e[0m"
      end
      print "\n#{PFX}  "
      0.upto(7) do |x|
        print "#{UTFC[x.even? == y.even?]}   \e[0m"
      end
      print "\n"
    end

    print "#{PFX}   0  1  2  3  4  5  6  7"
  end

  def hashify_pieces(pieces, hash=Hash.new)
    [*(0..7)].product([*(0..7)]).each do |square|
      pieces.each { |p| hash[square] = p if p.position == square }
    end

    hash
  end
end


