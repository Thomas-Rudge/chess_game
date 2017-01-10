require 'spec_helper'
require_relative '../pieces/pawn'

describe Pawn do
  let (:game)  { Game.new("empty") }
  let (:wpawn) { game.game_pieces << Pawn.new(0, [3, 3], [0, 7], game) }
  let (:bpawn) { game.game_pieces << Pawn.new(1, [6, 3], [0, 7], game) }
  describe "#valid_moves" do
    context "with no blocking pieces" do
      it "will only return the square in front of the pawn" do
        expect(wpawn.valid_moves.flatten(1)).to eql [[3, 4], [3, 5]]
        expect(bpawn.valid_moves.flatten(1)).to eql [[6, 2], [6, 1]]

        game.piece_in_position([3, 3]).position = [3, 4]
        game.piece_in_position([6, 3]).position = [6, 2]

        expect(wpawn.valid_moves.flatten(1)).to eql [[3, 5]]
        expect(bpawn.valid_moves.flatten(1)).to eql [[6, 1]]
      end
    end

    context "with a takable piece" do
      it "will return the square in front as a move, and the diagonal square as attackable" do
        game.game_pieces << Rook.new(1, [4, 4], [0, 7], game)
        game.game_pieces << Bishop.new(0, [7, 2], [0, 7], game)

        expect(wpawn.valid_moves).to eql [[[3, 4], [3, 5]], [[4, 4]], []]
        expect(bpawn.valid_moves).to eql [[[6, 2], [6, 1]], [[7, 2]], []]
      end
    end

    context "when blocked by a piece" do
      it "will return empty valid moves" do
        game.game_pieces << Rook.new(1, [3, 4], [0, 7], game)
        game.game_pieces << Bishop.new(0, [6, 2], [0, 7], game)

        expect(wpawn.valid_moves).to eql [[], [], []]
        expect(bpawn.valid_moves).to eql [[], [], []]
      end
    end

    context "when a piece of the same colour sits in a takable square" do
      it "will mark the piece as ally" do
        game.game_pieces << Rook.new(0, [4, 4], [0, 7], game)
        game.game_pieces << Bishop.new(1, [7, 2], [0, 7], game)

        expect(wpawn.valid_moves).to eql [[[3, 4], [3, 5]], [], [[4, 4]]]
        expect(bpawn.valid_moves).to eql [[[6, 2], [6, 1]], [], [[7, 2]]]
      end
    end
  end
end
