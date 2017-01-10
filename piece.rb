class Piece

  attr_accessor :history
  attr_reader   :colour, :boundary, :position
  attr_writer   :captured

  def initialize(colour, position, boundary, game)
    @colour   = colour
    @position = position
    @captured = false
    @history  = Array.new
    @boundary = boundary
    @game     = game
  end

  def callout(position)
    return self if position == @position
  end

  def available?
    captured? ? false : @colour == @game.turn
  end

  def takable?
    captured? ? false : !(@colour == @game.turn)
  end

  def reset
    @position = @history[0] unless @history.empty?
  end

  def clear_history!; @history.clear end
###### G E T T I N G   N O D E S #####################
  def xy_nodes_from_position(positions = Array.new)
    empty1, enemy1, ally1 = *x_axes
    empty2, enemy2, ally2 = *y_axes

    positions << empty1 + empty2
    positions << enemy1 + enemy2
    positions << ally1  + ally2

    positions
  end

  def verticle_nodes_from_position(positions = Array.new)
    empty1, enemy1, ally1 = *upper_right_verticles
    empty2, enemy2, ally2 = *upper_left_verticles
    empty3, enemy3, ally3 = *lower_left_verticles
    empty4, enemy4, ally4 = *lower_right_verticles

    positions << empty1 + empty2 + empty3 + empty4
    positions << enemy1 + enemy2 + enemy3 + enemy4
    positions << ally1  + ally2  + ally3  + ally4

    positions
  end

  def y_axes(positions = [[], [], []])
    [:+, :-].each do |operator|
      loop.with_index(1) do |_, i|
        val = [@position[0], @position[1].method(operator).call(i)]
        break unless val_in_bounds?(val)

        piece = @game.piece_in_position(val)
        unless piece.nil?
          piece.colour == @colour ? positions[2] << val : positions[1] << val
          break
        end

        positions[0] << val
      end
    end

    positions
  end

  def x_axes(positions = [[], [], []])
    [:+, :-].each do |operator|
      loop.with_index(1) do |_, i|
        val = [@position[0].method(operator).call(i), @position[1]]
        break unless val_in_bounds?(val)

        piece = @game.piece_in_position(val)
        unless piece.nil?
          piece.colour == @colour ? positions[2] << val : positions[1] << val
          break
        end

        positions[0] << val
      end
    end

    positions
  end

  def upper_right_verticles(positions = [[], [], []])
    loop.with_index(1) do |_, i|
      val = [@position[0] + i, @position[1] + i]
      break unless val_in_bounds?(val)

      piece = @game.piece_in_position(val)
      unless piece.nil?
        piece.colour == @colour ? positions[2] << val : positions[1] << val
        break
      end

      positions[0] << val
    end

    positions
  end

  def lower_left_verticles(positions = [[], [], []])
    loop.with_index(1) do |_, i|
      val = [@position[0] - i, @position[1] - i]
      break unless val_in_bounds?(val)

      piece = @game.piece_in_position(val)
      unless piece.nil?
        piece.colour == @colour ? positions[2] << val : positions[1] << val
        break
      end

      positions[0] << val
    end

    positions
  end

  def upper_left_verticles(positions = [[], [], []])
    loop.with_index(1) do |_, i|
      val = [@position[0] - i, @position[1] + i]
      break unless val_in_bounds?(val)

      piece = @game.piece_in_position(val)
      unless piece.nil?
        piece.colour == @colour ? positions[2] << val : positions[1] << val
        break
      end

      positions[0] << val
    end

    positions
  end

  def lower_right_verticles(positions = [[], [], []])
    loop.with_index(1) do |_, i|
      val = [@position[0] + i, @position[1] - i]

      break unless val_in_bounds?(val)
      piece = @game.piece_in_position(val)
      unless piece.nil?
        piece.colour == @colour ? positions[2] << val : positions[1] << val
        break
      end

      positions[0] << val
    end

    positions
  end

  def val_in_bounds?(val)
    (val[0].between? *@boundary) && (val[1].between? *@boundary)
  end
##### S E T T E R S  n  G E T T E R S ########################
  def captured?; @captured end

  def position=(value)
    @history << @position
    @position = value
  end
end
