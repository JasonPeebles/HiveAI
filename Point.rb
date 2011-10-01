class Point
  require 'set'
  include Comparable
  attr_accessor :x, :y
  
  def initialize (xCoord=0, yCoord=0)
    @x, @y = xCoord, yCoord
  end
  
  def to_s
    "(#{@x}, #{@y})"
  end
  
  # 'Dictionary ordering'
  def <=>(otherPoint)
    if (@x==otherPoint.x)
      @y<=>otherPoint.y
    else
      @x<=>otherPoint.x
    end
  end
    
  def + (otherPoint)
    Point.new(@x + otherPoint.x, @y + otherPoint.y)
  end
  
  def * (scalar)
    Point.new(scalar*@x, scalar*@y)
  end
  
  def - (otherPoint)
    self + (otherPoint*-1)
  end
  
  def isConnected?(otherPoint)
    diff = self - otherPoint
    max = if diff.x.abs > diff.y.abs then diff.x.abs else diff.y.abs end
    max == 1 and (diff.x*diff.y == 0 or diff.x + diff.y == 0)
  end
  
  # Equivalent defn: all Points for which self.isConnected?(p) is true
  def self.unitDisc(p)
    [
        Point.new(p.x + 1, p.y),
        Point.new(p.x - 1, p.y),
        Point.new(p.x, p.y + 1),        
        Point.new(p.x, p.y - 1),        
        Point.new(p.x + 1, p.y - 1),        
        Point.new(p.x - 1, p.y + 1)
    ]
   end
end
