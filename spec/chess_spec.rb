require 'spec_helper'
require_relative '../chess'

describe Game do
  let (:game) { Game.new }
  describe "#setup" do
    it "will add 1 white king to @game_pieces array" do
      expect(game.game_pieces.count do |piece|
               (piece.is_a? King) &&
               (piece.colour == 0)
             end).to eql 1
    end
  end
end
