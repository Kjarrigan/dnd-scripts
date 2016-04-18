# Changes to ruby core classes
module CoreExt
  VERSION = '0.1.0'
end

class Integer
  def pp
    self * 1000
  end

  def gp
    self * 100
  end

  def sp
    self * 10
  end

  def cp
    self
  end
end
