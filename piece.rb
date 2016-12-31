class Piece

  attr_accessor :history
  attr_reader   :colour, :boundary, :position
  attr_writer   :catpured

  def initialize(colour, position, boundary)
    @colour   = colour
    @position = position
    @history  = Array.new
    @boundary = boundary
    @captured = false
  end

  def callout(position)
    return self if position == @position
  end

  def reset
    @position = @history[0] unless @history.empty?
  end

  def clear_history
    @history.clear
    @history << @positions
  end
###### G E T T I N G   N O D E S #####################
  def xy_nodes_from_position(positions = Array.new)
    positions += x_axes
    positions += y_axes

    positions
  end

  def verticle_nodes_from_position(positions = Array.new)
    positions += upper_right_verticles
    positions += upper_left_verticles
    positions += lower_left_verticles
    positions += lower_right_verticles

    positions
  end

  def y_axes(positions = Array.new)
    [@position[0]].product([*(@boundary[0]..@boundary[1])]).each do |p|
      positions << p unless p == @position
    end

    positions
  end

  def x_axes(positions = Array.new)
    [@position[1]].product([*(@boundary[0]..@boundary[1])]).each do |p|
      positions << [p[1], p[0]] unless [p[1], p[0]] == @position
    end

    positions
  end

  def upper_right_verticles(positions = Array.new)
    # Add upper right verticles
    loop.with_index do |_, i|
      positions << [@position[0] + i, @position[1] + i]
      break if positions[-1][0] == @boundary[1] || positions[-1][1] == @boundary[1]
    end

    positions[1..-1]
  end

  def lower_left_verticles(positions = Array.new)
    # Add lower left verticles
    loop.with_index do |_, i|
      positions << [@position[0] - i, @position[1] - i]
      break if positions[-1][0] == @boundary[0] || positions[-1][1] == @boundary[0]
    end

    positions[1..-1]
  end

  def upper_left_verticles(positions = Array.new)
    # Add upper left verticles
    loop.with_index do |_, i|
      positions << [@position[0] - i, @position[1] + i]
      break if positions[-1][0] == @boundary[0] || positions[-1][1] == @boundary[1]
    end

    positions[1..-1]
  end

  def lower_right_verticles(positions = Array.new)
    # Add lower right verticles
    loop.with_index do |_, i|
      positions << [@position[0] + i, @position[1] - i]
      break if positions[-1][0] == @boundary[1] || positions[-1][1] == @boundary[0]
    end

    positions[1..-1]
  end
##### S E T T E R S  n  G E T T E R S ########################
  def captured?; @captured end

  def position=(value)
    @history << @position
    @position = value
  end
end
