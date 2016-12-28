require 'spec_helper'
require_relative '../pieces/knight'

describe Knight do
  let (:knight) { Knight.new(0, [0,0]) }

  describe "#valid_moves" do
    context "on the edge of the board" do
      it "returns only moves within the board" do
        knight.position = [7, 0]
        expect(knight.valid_moves.sort).to eql [[5, 1], [6, 2]]
      end
    end

    context "in the middle of the board" do
     it "returns all valid moves" do
       knight.position = [4, 3]
       expect(knight.valid_moves.sort).to eql [[2, 2], [2, 4], [3, 1], [3, 5],
                                               [5, 1], [5, 5], [6, 2], [6, 4]]
     end
    end
  end
end
