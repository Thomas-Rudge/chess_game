class Piece

  attr_accessor :position
  attr_reader   :colour

  def initialize(colour, position)
    @colour   = colour
    @position = position
    @start    = position
  end

  def callout(position)
    return self if position == @position
  end

  def reset
    @position = @start
  end

  def xy_from_position
    positions = Array.new
    # Add positions on X axis
    [@position[0]].product([*(0..7)]).each do |p|
      positions << p unless p == @position
    end
    # Add positions on Y axis
    [@position[1]].product([*(0..7)]).each do |p|
      positions << [p[1], p[0]] unless [p[1], p[0]] == @position
    end

    positions
  end

  def verticles_from_position
    positions = Array.new
    # Add upper right verticles
    loop.with_index do |_, i|
      positions << [@position[0] + i, @position[1] + i]
      break if positions[-1][0] == 7 || positions[-1][1] == 7
    end
    # Add lower left verticles
    loop.with_index do |_, i|
      positions << [@position[0] - i, @position[1] - i]
      break if positions[-1][0] == 0 || positions[-1][1] == 0
    end
    # Add upper left verticles
    loop.with_index do |_, i|
      positions << [@position[0] - i, @position[1] + i]
      break if positions[-1][0] == 0 || positions[-1][1] == 7
    end
    # Add lower right verticles
    loop.with_index do |_, i|
      positions << [@position[0] + i, @position[1] - i]
      break if positions[-1][0] == 7 || positions[-1][1] == 0
    end
    # Remove all the current positions
    positions.uniq!
    positions -= [@position]
  end
end
