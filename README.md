# Chess
A two player shell based chess game.

```ruby
require 'chess'

Game.new.start
```
A new game will start, with white on the bottom and black on the top.

![New_Game](screen_shots/new_game.jpg?raw=true "New Game")

Moves are inputted as coordinates corresponding to the labelled axes, from position, to position.

![Almost_Checkmate](screen_shots/almost_checkmate.jpg?raw=true "Almost Checkmate")

You can perform castling by typing `cr` or `cl` as a move.

Pawns are automatically promoted to Queens when they reach the end of the board.

En passant move is currently not supported.

---

### Accessing the Game class
```ruby
chess = Game.new

# Alternatively you can start with an empty chess board
chess = Game.new("empty")

# Calling the setup method will clear the board, and create 
# new pieces in their normal starting position
chess.setup

# If you created a game with a custom starting position, you can call restart to
# put the pieces back where they were at the beginning of the game.
chess.restart
```
You can see what pieces are on the board, and add new ones, by using the `game_pieces` instance variable.
```ruby
# Adding a new knight to the board
# The arguments passed are:
#    > colour: 0 - White, 1 - Black
#    > position: [x, y]
#    > boundary: [x.max, y.max]  *usually [0, 7] for an 8x8 board.
#    > The game it belongs to.
chess.game_pieces << Knigh.new(0, [4, 5], [0, 7], chess)

# Get all pieces that haven't been used yet
chess.game_pieces.select { |p| p.history.empty? }

# Get all pieces that have been captured
chess.game_pieces.select { |p| p.captured? }

# Remove all pieces from the board
chess.game_pieces.clear
```
There are various other methods to get pieces and check the state of current gameplay.
When referring to the opponent, it is the player not currently taking a turn.
```ruby
# Found out whether the opponent is capable of attacking a square
chess.position_under_attack?([6, 2])
 => false

# Get an array of all pieces that are currently capable of attacking a certain square.
# The second argument is the player doing the getting, so the example will look at white pieces only.
chess.get_attackers_of_position([3, 6], 1)

# Get a list of all squares that can be moved to (without exposing the king) in the current turn
chess.all_valid_moves
 => [[2, 2], [3, 6], [8, 1]]

# Get a list of all squares the king can move to.
chess.all_kings_moves
 => [[4, 1], [5, 0]]

# Get the piece from a particular position.
knight = chess.piece_in_position([1, 4])
 => #<Knight:0x00000000b772d0 @colour=0, @position=[1, 4], @history=[[1, 0], [2, 2]], @boundary=[0, 7], @captured=false, @game=#<Game:0x00000000b77528>>

# Get the range between two squares (only horizontal, vertical, and diagonal).
chess.range_between_squares([3, 1], [6, 5])
 => [[4, 2], [5, 3], [6, 4]] 

# Get all game pieces found between a range of squares
pieces = chess.pieces_in_range([3, 1], [6, 5])

# Get both kings
kings = chess.get_kings

# Check whether a move will expose a king to check
chess.does_move_expose_king?(knight, [3, 3], king)
 => true

# Force the game to check and update the status of each king 
# (whether in check or not), then returns both king pieces.
chess.update_status_of_kings

# Force the game to check the current state of the game (checkmate/stalemate).
# Use checkmate? stalemate? to confirm any change.
chess.checkmate?
 => false
chess.check_game_state
chess.checkmate?
 => true
``` 
---
### Accessing the Piece classes
Game pieces also have methods and attributes that can be accessed.
```ruby
Bishop = chess.piece_in_position([1, 4])

Bishop.captured?
 => false
Bishop.captured = true # Will no longer be considered for gameplay/

Bishop.colour
 =>1 # Black

# Can the piece be used in the next turn
Bishop.available?
 => false

Bishop.position
 =>[1, 4]

# Squares visited by the piece in the current game.
Bishop.history
 => [[1, 0], [2, 2]]

# If you do this chess.restart and piece.reset will consider the 
# piece's current square as its starting square for a new game.
Bishop.clear_history
 =>[]

# This will put the piece back on the square it started on when the game began.
# Note that it will not first check as to whether the square is free.
Bishop.reset

# For every piece, valid_moves returns an array of three arrays. The first
# array lists all empty squares that can be moved to. The second array lists
# all squares occupied by an opponent piece that can be captured. The third
# array lists all allied pieces that are blocking the piece's path.
Bishop.valid_moves
 => [[[2, 5], [3, 6], [4, 7], [0, 5], [0, 3], [2, 3], [3, 2], [4, 1], [5, 0]], [], []] 

# Only available on King pieces
white_king.in_check?
 => true
```
These methods are similar to the `valid_moves` method in what they return, but whether the positions returned are reachable will depend on the type of piece calling the method.
```ruby
# All squares going out diagonally from the pieces position.
Bishop.verticle_nodes_from_position
 => [[[2, 5], [3, 6], [4, 7], [0, 5], [0, 3], [2, 3], [3, 2], [4, 1], [5, 0]], [], []]

# All squares going out horizontally and vertically from the pieces position.
Bishop.xy_nodes_from_position
 => [[[2, 4], [3, 4], [4, 4], [5, 4], [6, 4], [7, 4], [0, 4], [1, 5], [1, 6], [1, 7], [1, 3], [1, 2], [1, 1], [1, 0]], [], []]

# All squares going out from the horizontal axis only
Bishop.y_axes
 => [[[1, 5], [1, 6], [1, 7], [1, 3], [1, 2], [1, 1], [1, 0]], [], []] 

# All squares going out from the vertical axis only
Bishop.x_axes
 => [[[2, 4], [3, 4], [4, 4], [5, 4], [6, 4], [7, 4], [0, 4]], [], []]

# All squares going out diagonally from the top right
Bishop.upper_right_verticles
 => [[[2, 5], [3, 6], [4, 7]], [], []] 

# All squares going out diagonally from the lower right
Bishop.lower_right_verticles
 => [[[2, 3], [3, 2], [4, 1], [5, 0]], [], []] 

# All squares going out diagonally from the lower left
Bishop.lower_left_verticles
 => [[[0, 3]], [], []] 

# All squares going out diagonally from the top left
Bishop.upper_left_verticles
 => [[[0, 5]], [], []] 
```

