require 'Move.rb'

class Piece
  attr_reader :colour, :type, :number
  attr_accessor :position
  attr_accessor :height
  
  def initialize(ident="")
    @colour = ident[0,1]
    @type = ident[1,1]
    @number = ident[2,1]
    @position = nil
    @height = 0
  end
  
  def identifier
    "#{@colour}#{@type}#{number}"
  end
  
  def to_s
    "#{identifier}#{@position}h#{@height}"
  end
  
  def eql?(otherPiece)
    self.identifier == otherPiece.identifier
  end
  
  def hash
    self.identifier.hash
  end
    
end

class HiveBoard
  attr_accessor :pieces
  attr_reader :upRight,:right,:downRight,:downLeft,:left,:upLeft
  
  def initialize()
    @pieces = Hash[
        "wA1", Piece.new("wA1"),
        "wA2", Piece.new("wA2"),
        "wA3", Piece.new("wA3"),
        "wG1", Piece.new("wG1"),
        "wG2", Piece.new("wG2"),
        "wG3", Piece.new("wG3"),
        "wB1", Piece.new("wB1"),
        "wB2", Piece.new("wB2"),
        "wS1", Piece.new("wS1"),
        "wS2", Piece.new("wS2"),
        "wQ", Piece.new("wQ"),
        "bA1", Piece.new("bA1"),
        "bA2", Piece.new("bA2"),
        "bA3", Piece.new("bA3"),
        "bG1", Piece.new("bG1"),
        "bG2", Piece.new("bG2"),
        "bG3", Piece.new("bG3"),
        "bB1", Piece.new("bB1"),
        "bB2", Piece.new("bB2"),
        "bS1", Piece.new("bS1"),
        "bS2", Piece.new("bS2"),
        "bQ", Piece.new("bQ")]
    
    # Convenience constants to indicate hex connectedness along a certain side
    # Note that Point.unitDisc(p) defn is equivalent to adding each of these direction
    # vectors to p and collecting the results
    # Also, for Points a,b a.isConnected?(b) returns true if and only if b-a is one of these direction vectors
    @upRight = Point.new(0,1)
    @right = Point.new(1,0)
    @downRight = Point.new(1,-1)
    @downLeft = @upRight*-1
    @left = @right*-1
    @upLeft = @downRight*-1
  end
  
  def piecesOnBoard()
    @pieces.values.select{|p| p.position}
  end
  
  def piecesAtPoint(p)
    piecesOnBoard.select{|piece| piece.position == p}
  end
  
  # p may be a Piece or a Point. Returns the pieces one away from that Piece or Point on board
  def piecesConnected(p)
    position = if p.kind_of?(Piece) then p.position elsif p.kind_of?(Point) then p else nil end
    pieces = []
    if position
      Point.unitDisc(position).each{|point| pieces |= piecesAtPoint(point)}
    end
    pieces
  end

  # p may be a Piece or a Point. Returns the empty board Points one away from p  
  def emptySpacesConnected(p)
    position = if p.kind_of?(Piece) then p.position elsif p.kind_of?(Point) then p else nil end
    if position
      Point.unitDisc(position).select{|point| piecesAtPoint(point).empty?}
    end
  end
    
  def gateBlocked?(a,b)
    if a.isConnected?(b)
      # By symmetry, we pick p to be the leftmost of a,b using the custom comparison operator. 
      # This way we only need consider 3 directions, those along the right half of the hex at p
      p = if a < b then a else b end #leftmost
      q = if b < a then a else b end #rightmost

      case q - p
        when @upRight then !(piecesAtPoint(p+@right).empty? or piecesAtPoint(p+@upLeft).empty?)
        when @right then !(piecesAtPoint(p+@upRight).empty? or piecesAtPoint(p+@downRight).empty?)
        when @downRight then !(piecesAtPoint(p+@right).empty? or piecesAtPoint(p+@downLeft).empty?)
      end
    
    else
      false
    end
  end
  
  def isConnected?()
    refPiece = piecesOnBoard[0]
    connectedPieces = [refPiece]
    branchPieces = piecesConnected(refPiece)
    
    while !branchPieces.empty?
      connectedPieces |= branchPieces
      newPieces = []
      branchPieces.each{|p| newPieces |= piecesConnected(p)}
      branchPieces = newPieces - connectedPieces
    end
    
    connectedPieces.count == piecesOnBoard.count
  end
  
  def commitMove(m)
    @pieces[m.pieceIdent].position=@pieces[m.destPiece].position + m.direction
  end
end    