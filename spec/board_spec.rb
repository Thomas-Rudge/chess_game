require 'spec_helper'
require_relative '../board'

describe Board do
  include Board

  describe "#check_response" do
    it "returns a false flag for invalid responses" do
      expect(check_response("Banana", [0, 7])[1]).to      be false
      expect(check_response("1,2 3,4 5,6", [0, 7])[1]).to be false
      expect(check_response("0,8 5,3", [0, 7])[1]).to     be false
    end

    it "returns an array of coordinates when given a valid response" do
      expect(check_response("5,2 6,3", [0, 7])).to eql [[[5,2],[6,3]], true]
    end
  end
end
