require 'spec_helper'
require_relative '../pieces/king'

describe King do
  let (:game) { Game.new("empty") }
  let (:king) { King.new(0, [0,0], [0, 7], game) }

  describe "#valid_moves" do
    context "on the edge of the board" do
      it "returns only moves within the board" do
        king.position = [7, 0]
        expect(king.valid_moves.flatten(1)).to match_array [[6, 0], [6, 1], [7, 1]]
      end
    end

    context "in the middle of the board" do
     it "returns all valid moves" do
       king.position = [2, 5]
       expect(king.valid_moves.flatten(1)).to match_array [[1, 4], [1, 5], [1, 6], [2, 4],
                                                           [2, 6], [3, 4], [3, 5], [3, 6]]
     end
    end
  end
end
