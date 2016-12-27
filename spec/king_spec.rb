require 'spec_helper'
require_relative '../pieces/king'

describe King do
  let (:king) { King.new(0, [0,0]) }

  describe "#valid_moves" do
    context "on the edge of the board" do
      it "returns only moves within the board" do
        king.position = [7, 0]
        expect(king.valid_moves).to include [7, 1], [6, 0], [6, 1]
        expect(king.valid_moves).not_to include [7, 0]
      end
    end

    context "in the middle of the board" do
     it "returns all valid moves" do
       king.position = [2, 5]
       expect(king.valid_moves).to include [3, 4], [3, 5], [3, 6], [2, 4], [2, 6], [1, 4], [1, 5], [1, 6]
       expect(king.valid_moves).not_to include [2, 5]
     end
    end
  end
end
