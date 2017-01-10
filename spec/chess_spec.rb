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

  describe "#range_between_squares" do
    it "will give all squares between two positions on the board" do
      expect(game.range_between_squares([3, 0], [3, 7])).to match_array [[3, 1], [3, 2], [3, 3],
                                                                        [3, 4], [3, 5], [3, 6]]
      expect(game.range_between_squares([7, 0], [3, 4])).to match_array [[4, 3], [5, 2], [6, 1]]
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
      expect(game.pieces_in_range(*range2)).to include(an_instance_of(Pawn))
      expect(game.pieces_in_range(*range3)).to include(an_instance_of(Queen))
    end
  end

  describe "#update_status_of_kings" do
    it "sets a king's in_check flag to true if he is under attack" do
      game.game_pieces.each { |p| p.captured = true if p.is_a? Pawn}

      expect(game.piece_in_position([4, 0]).in_check?).to be false
      expect(game.piece_in_position([4, 7]).in_check?).to be false

      game.piece_in_position([3, 7]).position = [4, 6]
      game.update_status_of_kings

      expect(game.piece_in_position([4, 0]).in_check?).to be true
      expect(game.piece_in_position([4, 7]).in_check?).to be false
    end
  end

  describe "#pawn_promotion" do
    it "replace Prawn objects that have reached the end of the board with Queen objects" do
      game.game_pieces.clear
      game.game_pieces << Pawn.new(0, [3, 6], [0, 7], game)
      game.game_pieces << Pawn.new(0, [5, 6], [0, 7], game)
      game.game_pieces << Pawn.new(1, [1, 1], [0, 7], game)
      game.game_pieces << Pawn.new(1, [5, 1], [0, 7], game)
      game.pawn_promotion

      expect(game.game_pieces).not_to include(an_instance_of(Queen))

      game.piece_in_position([3, 6]).position = [3, 7]
      game.piece_in_position([1, 1]).position = [1, 0]
      game.pawn_promotion

      expect(game.piece_in_position([3, 7])).to be_an_instance_of(Queen)
      expect(game.game_pieces.select { |p| p.position == [3,7] && !p.captured? }.length ).to eql 1
      expect(game.piece_in_position([1, 0])).to be_an_instance_of(Queen)
      expect(game.piece_in_position([5, 6])).to be_an_instance_of(Pawn)
      expect(game.piece_in_position([5, 1])).to be_an_instance_of(Pawn)
    end
  end

  describe "#get_attackers_of_position" do
    context "when a pawn is blocked" do
      it "will still consider the square diagonal to the pawn as under attack" do
        game.game_pieces.clear
        game.game_pieces << King.new(0, [5, 0], [0, 7], game)
        game.game_pieces << Pawn.new(1, [5, 1], [0, 7], game)

        expect(game.get_attackers_of_position([4, 0], 0)).to include(an_instance_of(Pawn))
      end
    end

    context "with multiple pieces" do
      let (:attackers) { game.get_attackers_of_position([2, 5], 0) }

      it "will return all opponent pieces attacking a square" do
        expect(attackers.count { |p| p.is_a? Knight} ).to eql 1
        expect(attackers.count { |p| p.is_a? Pawn}   ).to eql 2
      end
    end
  end

  describe "#all_kings_moves" do
    context "when an adjacent square is under attack" do
      it "will not be included as a move" do
        game.game_pieces.clear
        game.game_pieces << King.new(0, [3, 5], [0, 7], game)
        game.game_pieces << Bishop.new(1, [1, 2], [0, 7], game)

        expect(game.all_kings_moves(game.piece_in_position([3, 5]))).not_to include([3, 4], [4, 5])
      end
    end
  end

  describe "#update_game_state" do
    context "neither king is in stalemate or checkmate" do
      it "will not declare stalemate or checkmate" do
        game.update_game_state
        expect(game.stalemate?).to be false
        expect(game.checkmate?).to be false

        game.turn = 1
        game.update_game_state
        expect(game.stalemate?).to be false
        expect(game.checkmate?).to be false
      end
    end

    context "when the king is not in check, but no move is possible" do
      it "will declare stalemate" do
        # Burn vs. Pilsbury, 1898
        game.game_pieces.clear
        game.game_pieces << King.new(1, [5, 7], [0, 7], game)
        game.game_pieces << Pawn.new(0, [5, 6], [0, 7], game)
        game.game_pieces << King.new(0, [5, 5], [0, 7], game)
        game.turn = 1
        game.update_game_state

        expect(game.stalemate?).to be true
        expect(game.checkmate?).to be false
        # Anand vs. Kramnik, 2007
        game.game_pieces.clear
        game.reset_game_history
        game.game_pieces << King.new(1, [5, 4], [0 ,7], game)
        game.game_pieces << Pawn.new(1, [5, 5], [0, 7], game)
        game.game_pieces << Pawn.new(1, [6, 6], [0, 7], game)
        game.game_pieces << King.new(0, [7, 4], [0, 7], game)
        game.game_pieces << Pawn.new(0, [7, 3], [0, 7], game)
        game.update_game_state

        expect(game.stalemate?).to be true
        expect(game.checkmate?).to be false
        # Bernstein vs. Smyslov, 1946
        game.game_pieces.clear
        game.reset_game_history
        game.game_pieces << King.new(1, [5, 4], [0, 7], game)
        game.game_pieces << Pawn.new(1, [5, 3], [0, 7], game)
        game.game_pieces << Rook.new(1, [1, 1], [0, 7], game)
        game.game_pieces << King.new(0, [5, 2], [0, 7], game)
        game.update_game_state

        expect(game.stalemate?).to be true
        expect(game.checkmate?).to be false
        # Troitsky vs. Vogt, 1896 (Many pieces on the board)
        game.game_pieces.clear
        game.reset_game_history
        game.game_pieces << King.new(1, [3, 7], [0, 7], game)
        game.game_pieces << Queen.new(1, [3, 0], [0, 7], game)
        game.game_pieces << Rook.new(1, [6, 5], [0, 7], game)
        game.game_pieces << Bishop.new(1, [1, 5], [0, 7], game)
        game.game_pieces << Bishop.new(1, [7, 2], [0, 7], game)
        game.game_pieces << Pawn.new(1, [0, 4], [0, 7], game)
        game.game_pieces << Pawn.new(1, [1, 6], [0, 7], game)
        game.game_pieces << Pawn.new(1, [2, 6], [0, 7], game)
        game.game_pieces << Pawn.new(1, [4, 4], [0, 7], game)
        game.game_pieces << Pawn.new(1, [5, 6], [0, 7], game)
        game.game_pieces << Pawn.new(1, [6, 6], [0, 7], game)
        game.game_pieces << King.new(0, [6, 0], [0, 7], game)
        game.game_pieces << Rook.new(0, [7, 0], [0, 7], game)
        game.game_pieces << Knight.new(0, [6, 2], [0, 7], game)
        game.game_pieces << Bishop.new(0, [0, 4], [0, 7], game)
        game.game_pieces << Pawn.new(0, [0, 3], [0, 7], game)
        game.game_pieces << Pawn.new(0, [1, 4], [0, 7], game)
        game.game_pieces << Pawn.new(0, [4, 3], [0, 7], game)
        game.game_pieces << Pawn.new(0, [7, 1], [0, 7], game)
        game.update_game_state

        expect(game.stalemate?).to be true
        expect(game.checkmate?).to be false
      end
    end

    context "when the king is in check and cannot get out" do
      it "will declare checkmate" do
        # Fool's mate
        game.piece_in_position([3, 7]).position = [7, 3]
        game.piece_in_position([4, 6]).position = [4, 4]
        game.piece_in_position([5, 1]).position = [5, 2]
        game.piece_in_position([6, 1]).position = [6, 3]
        game.update_status_of_kings
        game.update_game_state

        expect(game.stalemate?).to be false
        expect(game.checkmate?).to be true
        # D. Byrne vs. Fischer
        game.game_pieces.clear
        game.game_pieces << King.new(1, [6, 6], [0, 7], game)
        game.game_pieces << Rook.new(1, [2, 1], [0, 7], game)
        game.game_pieces << Knight.new(1, [2, 2], [0, 7], game)
        game.game_pieces << Bishop.new(1, [1, 2], [0, 7], game)
        game.game_pieces << Bishop.new(1, [1, 3], [0, 7], game)
        game.game_pieces << Pawn.new(1, [1, 4], [0, 7], game)
        game.game_pieces << Pawn.new(1, [2, 5], [0, 7], game)
        game.game_pieces << Pawn.new(1, [5, 6], [0, 7], game)
        game.game_pieces << Pawn.new(1, [6, 5], [0, 7], game)
        game.game_pieces << Pawn.new(1, [7, 4], [0, 7], game)
        game.game_pieces << King.new(0, [2, 0], [0, 7], game)
        game.game_pieces << Queen.new(0, [1, 7], [0, 7], game)
        game.game_pieces << Knight.new(0, [4, 4], [0, 7], game)
        game.game_pieces << Pawn.new(0, [6, 1], [0, 7], game)
        game.game_pieces << Pawn.new(0, [7, 3], [0, 7], game)
        game.update_status_of_kings
        game.update_game_state

        expect(game.stalemate?).to be false
        expect(game.checkmate?).to be true

        # Simple with Rook
        game.game_pieces.clear
        game.game_pieces << King.new(1, [7, 4], [0, 7], game)
        game.game_pieces << King.new(0, [5, 5], [0, 7], game)
        game.game_pieces << Rook.new(0, [7, 0], [0, 7], game)
        game.turn = 1
        game.update_status_of_kings
        game.update_game_state

        expect(game.stalemate?).to be false
        expect(game.checkmate?).to be true
      end
    end

    context "if the king is in check, but can move out of the way" do
      it "will not declare checkmate" do
        game.game_pieces.clear
        game.game_pieces << King.new(1, [0, 7], [0, 7], game)
        game.game_pieces << King.new(0, [4, 0], [0, 7], game)
        game.game_pieces << Rook.new(0, [0, 0], [0, 7], game)
        game.game_pieces << Bishop.new(0, [3, 4], [0, 7], game)
        game.turn = 1
        game.update_status_of_kings
        game.update_game_state

        expect(game.stalemate?).to be false
        expect(game.checkmate?).to be false

      end
    end

    context "if the king is in check, but the attacker can be captured" do
      it "will not declare checkmate" do
        game.game_pieces.clear
        game.game_pieces << King.new(1, [4, 7], [0, 7], game)
        game.game_pieces << Rook.new(1, [7, 4], [0, 7], game)
        game.game_pieces << King.new(0, [7, 0], [0, 7], game)
        game.game_pieces << Rook.new(0, [6, 0], [0, 7], game)
        game.game_pieces << Pawn.new(0, [6, 1], [0, 7], game)
        game.game_pieces << Rook.new(0, [2, 4], [0, 7], game)
        game.update_status_of_kings
        game.update_game_state

        expect(game.stalemate?).to be false
        expect(game.checkmate?).to be false
      end
    end
  end

  describe "#format_response" do
    it "returns nil for invalid responses" do
      expect(game.format_response "Banana").to be_nil
      expect(game.format_response "1,23,4").to be_nil
      expect(game.format_response "08,53").to  be_nil
    end

    it "returns an array of coordinates when given a valid response" do
      expect(game.format_response "5,2 6,3").to eql [[5,2],[6,3]]
    end
  end

  describe "#user_response_valid?" do
    let (:bad_response)  { game.format_response "5,9 6,3" }
    let (:good_response) { game.format_response "5,2 6,3" }

    it "returns false when user response outside of boundaries" do
      expect(game.user_response_valid? bad_response).to be false
    end

    it "returns true when user response within boundaries" do
      expect(game.user_response_valid? good_response).to be true
    end
  end
end
