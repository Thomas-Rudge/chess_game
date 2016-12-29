require 'spec_helper'
require_relative '../chess'

describe Game do
  let (:game) { Game.new }
  describe "#setup" do
    it "will add a white & black king to @game_pieces array" do
      expect(game.game_pieces.count { |p| p.is_a? King }).to eql 2
      expect(game.game_pieces.select{ |p| p.is_a? King }.map { |k| k.colour }.inject(:+)).to eql 1
      expect(game.game_pieces.select{ |p| p.is_a? King }.map { |k| k.position }).to include [4, 0], [4, 7]
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

  describe "#attempt_castling" do
  end

  describe "#get_rook_and_king" do
  end

  describe "#range_between_pieces" do
  end

  describe "#piece_in_range" do
    let (:range1) { game.range_between_pieces([2, 6], [2, 2]) }
    let (:range2) { game.range_between_pieces([6, 3], [6, 7]) }
    let (:range3) { game.range_between_pieces([2, 7], [7, 7]) }

    it "returns nil if no pieces found" do
      expect(game.piece_in_range(range1)).to be_nil
    end

    it "return the first piece found" do
      expect(game.piece_in_range(range2)).to be_a(Pawn)
      expect(game.piece_in_range(range3)).to be_a(Queen)
    end
  end
end
