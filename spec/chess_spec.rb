require 'spec_helper'
require_relative '../chess'

describe Game do
  let (:game) { Game.new }
  describe "#setup" do
    it "will add a white & black king to @game_pieces array" do
      expect(game.game_pieces.count { |p| p.is_a? King }).to eql 2
      expect(game.game_pieces.select{ |p| p.is_a? King }.map { |k| k.colour }.inject(:+)).to eql 1
      expect(game.game_pieces.select{ |p| p.is_a? King }.map { |k| k.position }).to include [3, 0], [3, 7]
    end

    it "will add a white & black queen to @game_pieces array" do
      expect(game.game_pieces.count { |p| p.is_a? Queen }).to eql 2
      expect(game.game_pieces.select{ |p| p.is_a? Queen }.map { |q| q.colour }.inject(:+)).to eql 1
    end

    it "will add 2 white & 2 black bishops to @game_pieces array" do
      expect(game.game_pieces.count { |p| p.is_a? Bishop }).to eql 4
      expect(game.game_pieces.select{ |p| p.is_a? Bishop }.map { |b| b.colour }.inject(:+)).to eql 2
    end

    it "will add 2 white & 2 black knights to @game_pieces array" do
      expect(game.game_pieces.count { |p| p.is_a? Knight }).to eql 4
      expect(game.game_pieces.select{ |p| p.is_a? Knight }.map { |k| k.colour }.inject(:+)).to eql 2
    end

    it "will add 2 white & 2 black rooks to @game_pieces array" do
      expect(game.game_pieces.count { |p| p.is_a? Rook }).to eql 4
      expect(game.game_pieces.select{ |p| p.is_a? Rook }.map { |r| r.colour }.inject(:+)).to eql 2
    end

    it "will add 8 white & 8 black pawns to @game_pieces array" do
      expect(game.game_pieces.count { |p| p.is_a? Pawn }).to eql 16
      expect(game.game_pieces.select{ |p| p.is_a? Pawn }.map { |p| p.colour }.inject(:+)).to eql 8
    end
  end
end
