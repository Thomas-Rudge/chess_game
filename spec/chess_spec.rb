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
    it "will perform castling to the right when nothing is in the way" do
      game.pieces_in_range([4, 0], [7, 0]).each { |p| p.captured = true }
      game.attempt_castling(:r)
      expect(game.piece_in_position([6, 0])).to be_instance_of(King)
      expect(game.piece_in_position([5, 0])).to be_instance_of(Rook)
    end

    it "will perform castlig to the left when nothing is in the way" do
      game.pieces_in_range([0, 0], [4, 0]).each { |p| p.captured = true }
      game.attempt_castling(:l)
      expect(game.piece_in_position([2, 0])).to be_instance_of(King)
      expect(game.piece_in_position([3, 0])).to be_instance_of(Rook)
    end

    it "will not castle when something is in the way" do
      game.attempt_castling(:l)
      expect(game.piece_in_position([2, 0])).to be_instance_of(Bishop)
      expect(game.piece_in_position([3, 0])).to be_instance_of(Queen)
    end

    it "will not castle if the King has been moved" do
      game.pieces_in_range([0, 0], [4, 0]).each { |p| p.captured = true }
      game.piece_in_position([4, 0]).position = [3, 0]
      game.piece_in_position([3, 0]).position = [4, 0]
      game.attempt_castling(:l)
      expect(game.piece_in_position([2, 0])).to be_nil
      expect(game.piece_in_position([3, 0])).to be_nil
    end

    it "will not castle if the Rook has been moved" do
      game.pieces_in_range([4, 0], [7, 0]).each { |p| p.captured = true }
      game.piece_in_position([7, 0]).position = [6, 0]
      game.piece_in_position([6, 0]).position = [7, 0]
      game.attempt_castling(:r)
      expect(game.piece_in_position([6, 0])).to be_nil
      expect(game.piece_in_position([5, 0])).to be_nil
    end

    it "will not castle if the king will pass through, or land on, a square under attack" do
      game.pieces_in_range([0, 0], [4, 0]).each { |p| p.captured = true }
      game.piece_in_position([2, 1]).captured = true
      game.piece_in_position([7, 7]).position = [2, 2]
      game.attempt_castling(:l)
      expect(game.piece_in_position([2, 0])).to be_nil
      expect(game.piece_in_position([3, 0])).to be_nil
    end
  end

  describe "#range_between_pieces" do
    it "will give all squares between two positions on the board" do
      expect(game.range_between_pieces([3, 0], [3, 7]).sort).to eql [[3, 1], [3, 2], [3, 3],
                                                                     [3, 4], [3, 5], [3, 6]]
      expect(game.range_between_pieces([7, 0], [3, 4]).sort).to eql [[4, 3], [5, 2], [6, 1]]
    end
  end

  describe "#pieces_in_range" do
    let (:range1) { [[2, 6], [2, 2]] }
    let (:range2) { [[6, 3], [6, 7]] }
    let (:range3) { [[2, 7], [7, 7]] }

    it "returns nil if no pieces found" do
      expect(game.pieces_in_range(*range1)).to be_empty
    end

    it "return the first piece found" do
      expect(game.pieces_in_range(*range2)).to include(a_kind_of(Pawn))
      expect(game.pieces_in_range(*range3)).to include(a_kind_of(Queen))
    end
  end
end
