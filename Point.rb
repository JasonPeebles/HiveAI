class Point
  require 'set'
  include Comparable
  attr_accessor :x, :y
  
  def initialize (xCoord=0, yCoord=0)
    @x, @y = xCoord, yCoord
  end
  
  def to_s
    "(#{@x},#{@y})"
  end
  
  def hash
   code = 17
   code = 37*code + @x.hash
   code = 37*code + @y.hash
   code
  end
  
  def eql?(other)
    if other.instance_of?(Point)
      @x.eql?(other.x) && @y.eql?(other.y)
    else
      false
    end
  end
  
  # 'Dictionary ordering'
  def <=>(otherPoint)
    if (@x.eql?(otherPoint.x))
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
  
  def add!(otherPoint)
    @x += otherPoint.x
    @y += otherPoint.y
    self
  end
  
  def subtract!(otherPoint)
    @x -= otherPoint.x
    @y -= otherPoint.y
    self
  end
  
  def scale!(scalar)
    @x = @x*scalar
    @y = @y*scalar
    self
  end
  
  def isConnected?(otherPoint)
    diff = self - otherPoint
    max = if diff.x.abs > diff.y.abs then diff.x.abs else diff.y.abs end
    max == 1 and (diff.x*diff.y == 0 or diff.x + diff.y == 0)
  end
  
  # Equivalent defn: all Points for which self.isConnected?(p) is true
  def self.unitDisc(p)
    Set[
        Point.new(p.x + 1, p.y),
        Point.new(p.x - 1, p.y),
        Point.new(p.x, p.y + 1),        
        Point.new(p.x, p.y - 1),        
        Point.new(p.x + 1, p.y - 1),        
        Point.new(p.x - 1, p.y + 1)
    ]
   end
end
