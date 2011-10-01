require 'HiveBoard.rb'

class HiveGame
  
  attr_reader :board, :moves
  
  def initialize()
    @board = HiveBoard.new
    @moves = []
    @Grasshopper = "G"
    @Queen = "Q"
    @Ant = "A"
    @Beetle = "B"
    @Spider = "S"
  end
  
  # def configureBoardWithMoves(s)
  #   s.split(',').each{|mString| self.commitMove(Move.new(mString))}
  # end
  # 
  # def commitMove(m)
  #   @board.commitMove(m)
  #   @moves.push(m)
  # end
  # 
  # def undoLastMove
  #   lastMove = @moves[-1]
  #   board.commitMove(@moves.pop.reverse.first{|m| m.pieceIdent == lastMove.pieceIdent})
  # end
  
  #Checks whether or not removing the piece from the board disconnects the board
  #Does NOT check for piece specific restrictions, gate blocks etc
  def pieceCanMove?(p)
    piece = if p.kind_of?(Piece) then p elsif p.kind_of?(String) then @board.pieces[p] end
    if piece.position.nil?
      false
    else
      #Remove piece from board, check if board remains connected
      temp = piece.position
      piece.position = nil
      connected = @board.isConnected?
      piece.position = temp
      return connected
    end
  end
  
  def movablePieces()
    @board.piecesOnBoard.select{|p| pieceCanMove?(p)}.collect{|p| p.identifier}
  end
  
  def movePiece(pieceIdent, x, y)
    @board.pieces[pieceIdent].position = if x.nil? or y.nil? then nil else Point.new(x,y) end
  end
  
  def movePositions(p)
    piece = if p.kind_of?(Piece) then p elsif p.kind_of?(String) then @board.pieces[p] end
    if @board.piecesOnBoard.include?(piece)
      puts "#{piece.identifier} already on board at #{piece.position}"
      if self.pieceCanMove?(piece)
        # Compute available spaces to move
        case piece.type
          when @Queen then queenMovePositions(piece.position)
          when @Spider then spiderMovePositions(piece.position)
          when @Ant then antMovePositions(piece.position)                         
          when @Beetle then beetleMovePositions(piece.position)                         
          when @Grasshopper then grasshopperMovePositions(piece.position)
        end                         
      else
        nil
      end
    else
      # Compute available spaces to place new piece
      candidates = []
      board.piecesOnBoard.each{|p| candidates += board.emptySpacesConnected(p)}

      #Pick out points which are only nearby pieces of piece.colour
      availableSpaces = candidates.select{|point|
        discColours = board.piecesConnected(point).collect{|pce| pce.colour}.uniq
        discColours.count == 1 and discColours[0] == piece.colour
      }.uniq
      
      puts "Available spaces to place #{piece.identifier}: #{availableSpaces.join(", ")}"      
    end
    
  end
  
  def queenMovePositions(position)
  end

  def spiderMovePositions(position)
  end

  def antMovePositions(position)
  end

  def beetleMovePositions(position)
  end

  def grasshoppeMovePositions(position)
  end

end