require 'spec_helper'
Dir["../piece.rb"].each { |file| load file }


describe Piece do
  let (:game) { Game.new }
  let (:piece) { Piece.new(0, [0, 0], [0, 7], game) }

  it "will have colour and position" do
    expect(piece).to have_attributes(:colour=>0)
    expect(piece).to have_attributes(:position=>[0, 0])
    expect(piece).to have_attributes(:boundary=>[0, 7])
  end

  describe "#callout" do
    it "will return nil when given an unkown position" do
      expect(piece.callout([0, 1])).to be_nil
    end

    it "will return itself when given its position" do
      expect(piece.callout([0, 0])).to equal piece
    end
  end

  describe "#xy_nodes_from_position" do
    context "when positioned at the end of the board" do
      it "gives all positions along the x and y axis relative to @position" do
        piece.position = [7, 4]
        expect(piece.xy_nodes_from_position.flatten(1)).to match_array [[0, 4], [1, 4], [2, 4],
                                                                        [3, 4], [4, 4], [5, 4],
                                                                        [6, 4], [7, 1], [7, 2],
                                                                        [7, 3], [7, 5], [7, 6]]
      end

    context "when positioned in the middle of the board" do
      it "gives all verticles positions relative to @positon" do
        piece.position = [4, 3]
        expect(piece.xy_nodes_from_position.flatten(1)).to match_array [[0, 3], [1, 3], [2, 3],
                                                                        [3, 3], [4, 1], [4, 2],
                                                                        [4, 4], [4, 5], [4, 6],
                                                                        [5, 3], [6, 3], [7, 3]]
      end
    end
    end
  end

  describe "#verticle_nodes_from_position" do
    context "when positioned at the end of the board" do
      it "gives all verticles positions relative to @position" do
        piece.position = [7, 4]
        expect(piece.verticle_nodes_from_position.flatten(1)).to match_array [[4, 1], [5, 2], [5, 6],
                                                                              [6, 3], [6, 5]]
      end
    end

    context "when positioned in the middle of the board" do
      it "gives all verticles positions relative to @positon" do
        piece.position = [4, 3]
        expect(piece.verticle_nodes_from_position.flatten(1)).to match_array [[1, 6], [2, 1], [2, 5],
                                                                              [3, 2], [3, 4], [5, 2],
                                                                              [5, 4], [6, 1], [6, 5],
                                                                              [7, 6]]
      end
    end
  end
end
