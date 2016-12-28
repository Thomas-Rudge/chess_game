class Piece

  attr_accessor :position, :history
  attr_reader   :colour, :boundary
  attr_writer   :catpured

  def initialize(colour, position, boundary)
    @colour   = colour
    @position = position
    @history  = [position]
    @boundary = boundary
    @captured = false
  end

  def callout(position)
    return self if position == @position
  end

  def reset
    @position = @history[0]
  end

  def clear_history
    @history.clear
    @history << @positions
  end

  def xy_from_position
    positions = Array.new
    # Add positions on X axis
    [@position[0]].product([*(@boundary[0]..@boundary[1])]).each do |p|
      positions << p unless p == @position
    end
    # Add positions on Y axis
    [@position[1]].product([*(@boundary[0]..@boundary[1])]).each do |p|
      positions << [p[1], p[0]] unless [p[1], p[0]] == @position
    end

    positions
  end

  def verticles_from_position
    positions = Array.new
    # Add upper right verticles
    loop.with_index do |_, i|
      positions << [@position[0] + i, @position[1] + i]
      break if positions[-1][0] == @boundary[1] || positions[-1][1] == @boundary[1]
    end
    # Add lower left verticles
    loop.with_index do |_, i|
      positions << [@position[0] - i, @position[1] - i]
      break if positions[-1][0] == @boundary[0] || positions[-1][1] == @boundary[0]
    end
    # Add upper left verticles
    loop.with_index do |_, i|
      positions << [@position[0] - i, @position[1] + i]
      break if positions[-1][0] == @boundary[0] || positions[-1][1] == @boundary[1]
    end
    # Add lower right verticles
    loop.with_index do |_, i|
      positions << [@position[0] + i, @position[1] - i]
      break if positions[-1][0] == @boundary[1] || positions[-1][1] == @boundary[0]
    end
    # Remove all the current positions
    positions.uniq!
    positions -= [@position]
  end

  def captured
    @captured
  end

  alias_method :captured?, :captured

end
