require 'spec_helper'
Dir["../piece.rb"].each { |file| load file }


describe Piece do
  let (:piece) { Piece.new(0, [0,0]) }

  it "will have colour and position" do
    expect(piece).to have_attributes(:colour=>0)
    expect(piece).to have_attributes(:position=>[0, 0])
  end

  describe "#callout" do
    it "will return nil when given an unkown position" do
      expect(piece.callout([0,1])).to be_nil
    end

    it "will return itself when given its position" do
      expect(piece.callout([0,0])).to equal piece
    end
  end
end
