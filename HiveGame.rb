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
      #Check if piece can move without breaking connection and if piece in on top of pile at point
      if self.pieceCanMove?(piece) && piece.height == @board.piecesAtPoint(piece.position).count-1
        # Compute available spaces to move
        position = piece.position
        piece.position = nil
        positions = Set[]
        case piece.type
          when @Queen then positions = queenMovePositions(position)
          when @Spider then positions = spiderMovePositions(position)
          when @Ant then positions = antMovePositions(position)                         
          when @Beetle then positions = beetleMovePositions(position)                         
          when @Grasshopper then positions = grasshopperMovePositions(position)
        end 
        piece.position = position
        positions                        
      else
        nil
      end
    else
      # Compute available spaces to place new piece
      candidates = Set[]
      board.piecesOnBoard.each{|p| candidates |= board.emptySpacesConnected(p)}

      #Pick out points which are only nearby pieces of piece.colour
      availableSpaces = candidates.select do |point|
        discColours = board.piecesConnected(point).collect!{|pce| pce.colour}.uniq
        discColours.count == 1 and discColours[0] == piece.colour
      end
      
      puts "Available spaces to place #{piece.identifier}: #{availableSpaces.uniq.join(", ")}"      
    end
    
  end
  
  def queenMovePositions(position)
    candidates = board.emptySpacesConnected(position).select{ |point| !board.gateBlocked?(position,point) }.to_set
    puts "Candidates #{candidates.to_a.join(", ")}"
    emptySpacesNearConnectedPieces = Set[]
    board.piecesConnected(position).each{|piece| emptySpacesNearConnectedPieces |= board.emptySpacesConnected(piece).to_set}
    puts "EmptySpaces #{emptySpacesNearConnectedPieces.to_a.join(", ")}"
    positions = candidates & emptySpacesNearConnectedPieces
    puts "Queen Moves from #{position}: #{positions.to_a.join(", ")}"
    positions
  end

  def spiderMovePositions(position)
    positions = Set[]
    branchPositions = queenMovePositions(position)
    startingPoint = Set[position]
    trail = Set[]
    trail |= branchPositions
    2.times do 
      newPositions = Set[]
      branchPositions.each{|p| newPositions |= queenMovePositions(p)}
      branchPositions = newPositions - trail - startingPoint
      trail |= branchPositions
    end
    positions |= branchPositions
    puts "Spider Moves from #{position}: #{positions.to_a.join(", ")}"
    positions
    
  end

  def antMovePositions(position)
    positions = Set[]
    branchPositions = queenMovePositions(position)
    startingPoint = Set[position]
    while (!branchPositions.empty?)
      positions |= branchPositions
      newPositions = Set[]
      branchPositions.each{|p| newPositions |= queenMovePositions(p)}
      branchPositions = newPositions - positions - startingPoint
    end
    puts "Ant Moves from #{position}: #{positions.to_a.join(", ")}"
    positions
  end

  def beetleMovePositions(position)
    #if height=0 return queen legal move positions together with the positions, else return unit disc
    positions = Set[]
    if board.piecesAtPoint(position).count==1
      positions = queenMovePositions(position) | board.piecesConnected(position).collect{|p| p.position}.to_set
    elsif board.piecesAtPoint(position).count>1
      positions = Point.unitDisc(position)
    end
    puts "Beetle Moves from #{position}: #{positions.to_a.join(", ")}"
    positions
  end

  def grasshopperMovePositions(position)
    directions = board.piecesConnected(position).collect{|p| p.position - position}
    positions = Set[]
    directions.each do |d|
      moveVector = d*2
      while (!board.piecesAtPoint(position + moveVector).empty?)
        moveVector.add!(d)
      end
      positions<<(moveVector.add!(position))
    end
    puts "Grasshopper Moves from #{position}: #{positions.to_a.join(", ")}"
    positions  
  end

end