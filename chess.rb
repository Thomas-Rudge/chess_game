Dir["pieces/*.rb"].each { |file| require_relative file }

class Game

  attr_reader :game_pieces

  def initialize
    @game_pieces = Array.new
    setup
  end

  def setup
    row = {0=>0, 1=>7}

    [0, 1].each do |colour| # 0 - White, 1 - Black
      @game_pieces << Rook.new(colour, [0, row[colour]])
      @game_pieces << Knight.new(colour, [1, row[colour]])
      @game_pieces << Bishop.new(colour, [2, row[colour]])
      @game_pieces << King.new(colour, [3, row[colour]])
      @game_pieces << Queen.new(colour, [4, row[colour]])
      @game_pieces << Bishop.new(colour, [5, row[colour]])
      @game_pieces << Knight.new(colour, [6, row[colour]])
      @game_pieces << Rook.new(colour, [7, row[colour]])
      # Add the pawns
      8.times { |i| @game_pieces << Pawn.new(colour, [i, (row[colour]-1).abs]) }
    end
  end
end
